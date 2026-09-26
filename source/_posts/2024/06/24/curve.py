import typing

from matplotlib import pyplot as plt
import numpy as np
from abc import ABC, abstractmethod
from dataclasses import dataclass


def vec2(x: int, y: int) -> np.ndarray:
    return np.array([x, y], dtype=np.int32)


def vec3(x: int, y: int, z: int) -> np.ndarray:
    return np.array([x, y, z], dtype=np.int32)


def vec2_to_vec3(v: np.ndarray) -> np.ndarray:
    return np.array([v[0], v[1], 1], dtype=np.int32)


def vec3_to_vec2(v: np.ndarray) -> np.ndarray:
    return np.array([v[0], v[1]], dtype=np.int32)


@dataclass
class Point2:
    x: int
    y: int

    def __str__(self):
        return f"({self.x}, {self.y})"

    def __add__(self, other: "Point2") -> "Point2":
        return Point2(self.x + other.x, self.y + other.y)

    def __sub__(self, other: "Point2") -> "Point2":
        return Point2(self.x - other.x, self.y - other.y)

    def __mul__(self, scalar: int) -> "Point2":
        return Point2(self.x * scalar, self.y * scalar)

    def __hash__(self):
        return hash((self.x, self.y))

    def to_numpy(self) -> np.ndarray:
        return vec3(self.x, self.y, 1)

    @classmethod
    def from_numpy(cls, point: np.ndarray) -> "Point2":
        p = vec3_to_vec2(point.round().astype(np.int32))
        return Point2(int(p[0]), int(p[1]))


class Curve(ABC):
    @abstractmethod
    def encode(self, point: Point2) -> int:
        pass

    @abstractmethod
    def decode(self, index: int) -> Point2:
        pass


class Transform:
    @abstractmethod
    def apply(self, point: np.ndarray, scale: int) -> np.ndarray:
        pass

    @abstractmethod
    def apply_inverse(self, point: np.ndarray, scale: int) -> np.ndarray:
        pass


class Rotation(Transform):

    @staticmethod
    def __rotation(angle: float) -> np.ndarray:
        c = np.cos(angle)
        s = np.sin(angle)
        return np.array(
            [
                [c, -s, 0],
                [s, c, 0],
                [0, 0, 1],
            ]
        )

    def __init__(self, angle: float):
        self.R = self.__rotation(angle)

    def apply(self, point: np.ndarray, scale: int) -> np.ndarray:
        return self.R @ point

    def apply_inverse(self, point: np.ndarray, scale: int) -> np.ndarray:
        return self.R.T @ point


class Translation(Transform):
    @staticmethod
    def __translation(trans: np.ndarray):
        return np.array(
            [
                [1, 0, trans[0]],
                [0, 1, trans[1]],
                [0, 0, 1],
            ]
        )

    def __init__(self, translation: np.ndarray):
        self.T = translation

    def apply(self, point: np.ndarray, scale: int) -> np.ndarray:
        return self.__translation(self.T * scale) @ point

    def apply_inverse(self, point: np.ndarray, scale: int) -> np.ndarray:
        return self.__translation(-self.T * scale) @ point


class Scale(Transform):
    @staticmethod
    def __scale(scale: np.ndarray):
        return np.array(
            [
                [scale[0], 0, 0],
                [0, scale[1], 0],
                [0, 0, 1],
            ]
        )

    def __init__(self, scale: np.ndarray) -> None:
        self.S = self.__scale(scale)
        self.S_inv = self.__scale(1 / scale)

    def apply(self, point: np.ndarray, scale: int) -> np.ndarray:
        return self.S @ point

    def apply_inverse(self, point: np.ndarray, scale: int) -> np.ndarray:
        return self.S_inv @ point


class CompositeTransform(Transform):
    def __init__(self, transforms: list[Transform]) -> None:
        self.__transforms = transforms

    def apply(self, point: np.ndarray, scale: int) -> np.ndarray:
        for t in reversed(self.__transforms):
            point = t.apply(point, scale)
        return point

    def apply_inverse(self, point: np.ndarray, scale: int) -> np.ndarray:
        for t in self.__transforms:
            point = t.apply_inverse(point, scale)
        return point


class Identity(Transform):
    def apply(self, point: np.ndarray, scale: int) -> np.ndarray:
        return point

    def apply_inverse(self, point: np.ndarray, scale: int) -> np.ndarray:
        return point


class HilbertCurve(Curve):
    def __init__(self, order: int):
        self.order = order

    block_map: typing.ClassVar[list[Point2]] = [
        Point2(0, 0),
        Point2(0, 1),
        Point2(1, 1),
        Point2(1, 0),
    ]

    block_id_map: typing.ClassVar[dict[Point2, int]] = {
        Point2(0, 0): 0,
        Point2(0, 1): 1,
        Point2(1, 1): 2,
        Point2(1, 0): 3,
    }

    # operation_map: typing.ClassVar[list[typing.Callable[[Point2, int], Point2]]] = [
    #     lambda point, order: Point2(point.y, point.x),
    #     lambda point, order: point,
    #     lambda point, order: point,
    #     lambda point, order: Point2(
    #         (1 << order) - 1 - point.y, (1 << order) - 1 - point.x
    #     ),
    # ]

    transform_map: typing.ClassVar[list[Transform]] = [
        CompositeTransform([Rotation(-np.pi / 2), Scale(vec2(-1, 1))]),
        Identity(),
        Identity(),
        CompositeTransform(
            [Translation(vec2(1, 1)), Rotation(-np.pi / 2), Scale(vec2(1, -1))]
        ),
    ]

    @classmethod
    def __base_point(cls, block_id: int, order: int) -> Point2:
        p = cls.block_map[block_id]
        return Point2(p.x << order, p.y << order)

    def encode(self, point: Point2) -> int:
        curr_order = self.order
        curr_point = point
        encoded_index = 0
        while curr_order > 0:
            curr_x = curr_point.x >> (curr_order - 1)
            curr_y = curr_point.y >> (curr_order - 1)
            block_id = self.block_id_map[Point2(curr_x, curr_y)]
            encoded_index += block_id * (1 << (2 * (curr_order - 1)))
            base_point = self.__base_point(block_id, curr_order - 1)
            relative_point = curr_point - base_point
            # convert to next order
            curr_point = Point2.from_numpy(
                self.transform_map[block_id].apply_inverse(
                    relative_point.to_numpy(),
                    (1 << curr_order - 1) - 1,
                )
            )
            curr_order -= 1
        return encoded_index

    def decode(self, index: int) -> Point2:
        curr_order = 0
        point = Point2(0, 0)
        while curr_order < self.order:
            block_id = index & 0b11
            index >>= 2
            base_point = self.__base_point(block_id, curr_order)
            # convert to next order
            point = (
                Point2.from_numpy(
                    self.transform_map[block_id].apply(
                        point.to_numpy(), (1 << curr_order) - 1
                    )
                )
                + base_point
            )
            curr_order += 1
        return point


class MortonZCurve(Curve):
    def __init__(self, order: int):
        self.order = order
        # index = x_bitN|y_bitN|x_bitN-1|y_bitN-1|...|x_bit0|y_bit0

    def encode(self, point: Point2) -> int:
        index = 0
        curr_order = self.order
        for i in range(curr_order):
            index |= ((point.x >> i) & 1) << (2 * i)
            index |= ((point.y >> i) & 1) << (2 * i + 1)
        return index

    def decode(self, index: int) -> Point2:
        x = 0
        y = 0
        curr_order = self.order
        for i in range(curr_order):
            x |= ((index >> (2 * i)) & 1) << i
            y |= ((index >> (2 * i + 1)) & 1) << i
        return Point2(x, y)


order = 3
hilbert_curve = HilbertCurve(order)
morton_curve = MortonZCurve(order)

hilbert_points_map = {}
morton_points_map = {}

for x in range(2**order):
    for y in range(2**order):
        point = Point2(x, y)
        hilbert_points_map[hilbert_curve.encode(point)] = point
        # morton_points_map[morton_curve.encode(point)] = point

for i in range(2 ** (2 * order)):
    assert hilbert_points_map[i] == hilbert_curve.decode(i)
    # assert morton_points_map[i] == morton_curve.decode(i)

# plt.plot(
#     [morton_points_map[i].x for i in range(2 ** (2 * order))],
#     [morton_points_map[i].y for i in range(2 ** (2 * order))],
#     marker="o",
# )

w = 16
h = 32

m = int(np.round(np.log2(w)))
n = int(np.round(np.log2(h)))

x_major = w >= h
y_major = h > w

k = n if x_major else m

print(y_major)

curve = HilbertCurve(order=k)

pnts = []

base_point = Point2(0, 0)
total = w * h
block_total = 2 ** (2 * k)
start = 0
while start < total:
    for i in range(min(block_total, total - start)):
        pnt = base_point + curve.decode(i)
        if x_major:
            pnts.append(pnt)
        else:
            pnts.append(Point2(pnt.y,pnt.x))
    base_point += Point2(1 << k, 0)
    start += block_total

print(pnts)

plt.plot(
    [p.x for p in pnts],
    [p.y for p in pnts],
    marker="x",
)

plt.show()

# print("All tests passed!")
