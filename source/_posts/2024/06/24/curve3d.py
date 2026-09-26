import typing

from matplotlib import pyplot as plt
import numpy as np
from abc import ABC, abstractmethod
from dataclasses import dataclass


def vec2(x: int, y: int) -> np.ndarray:
    return np.array([x, y], dtype=np.int32)


def vec3(x: int, y: int, z: int) -> np.ndarray:
    return np.array([x, y, z], dtype=np.int32)


def vec4(x: int, y: int, z: int, w: int) -> np.ndarray:
    return np.array([x, y, z, w], dtype=np.int32)


def vec3_to_vec4(v: np.ndarray) -> np.ndarray:
    return np.array([v[0], v[1], v[2], 1], dtype=np.int32)


def vec4_to_vec3(v: np.ndarray) -> np.ndarray:
    return np.array([v[0], v[1], v[2]], dtype=np.int32)


@dataclass
class Point3:
    x: int
    y: int
    z: int

    def __str__(self):
        return f"({self.x}, {self.y}, {self.z})"

    def __add__(self, other: "Point3") -> "Point3":
        return Point3(self.x + other.x, self.y + other.y, self.z + other.z)

    def __sub__(self, other: "Point3") -> "Point3":
        return Point3(self.x - other.x, self.y - other.y, self.z - other.z)

    def __mul__(self, scalar: int) -> "Point3":
        return Point3(self.x * scalar, self.y * scalar, self.z * scalar)

    def __hash__(self):
        return hash((self.x, self.y, self.z))

    def to_numpy(self) -> np.ndarray:
        return vec4(self.x, self.y, self.z, 1)

    @classmethod
    def from_numpy(cls, point: np.ndarray) -> "Point3":
        p = vec4_to_vec3(point.round().astype(np.int32))
        return Point3(int(p[0]), int(p[1]), int(p[2]))


class Curve3D(ABC):
    @abstractmethod
    def encode(self, point: Point3) -> int:
        pass

    @abstractmethod
    def decode(self, index: int) -> Point3:
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
    def __rotation(axis: np.ndarray, angle: float) -> np.ndarray:
        axis = np.asarray(axis, dtype=float)
        axis /= np.linalg.norm(axis)

        x, y, z = axis
        c = np.cos(angle)
        s = np.sin(angle)
        t = 1 - c

        return np.array(
            [
                [t * x * x + c, t * x * y - s * z, t * x * z + s * y, 0],
                [t * x * y + s * z, t * y * y + c, t * y * z - s * x, 0],
                [t * x * z - s * y, t * y * z + s * x, t * z * z + c, 0],
                [0, 0, 0, 1],
            ]
        )

    def __init__(self, axis: np.ndarray, angle: float):
        self.R = self.__rotation(axis, angle)

    def apply(self, point: np.ndarray, scale: int) -> np.ndarray:
        return self.R @ point

    def apply_inverse(self, point: np.ndarray, scale: int) -> np.ndarray:
        return self.R.T @ point


class Translation(Transform):
    @staticmethod
    def __translation(trans: np.ndarray):
        return np.array(
            [
                [1, 0, 0, trans[0]],
                [0, 1, 0, trans[1]],
                [0, 0, 1, trans[2]],
                [0, 0, 0, 1],
            ]
        )

    def __init__(self, translation: np.ndarray):
        self.translation = translation

    def apply(self, point: np.ndarray, scale: int) -> np.ndarray:
        return self.__translation(self.translation * scale) @ point

    def apply_inverse(self, point: np.ndarray, scale: int) -> np.ndarray:
        return self.__translation(-self.translation * scale) @ point


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


def plot_seq(seq, title="", show_index: bool = False):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection="3d", title=title)

    ax.plot(
        [pnt[0] for pnt in seq],
        [pnt[1] for pnt in seq],
        [pnt[2] for pnt in seq],
        marker="o",
    )

    if show_index:
        for i, pnt in enumerate(seq):
            ax.text(pnt[0], pnt[1], pnt[2], str(i))

    # ax.set_xlim([-1, 1])
    # ax.set_ylim([-1, 1])
    # ax.set_zlim([-1, 1])
    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.set_zlabel("Z")
    return ax


class HilbertCurve(Curve3D):
    def __init__(self, order: int):
        self.order = order

    block_map: typing.ClassVar[list[Point3]] = [
        Point3(0, 0, 0),
        Point3(1, 0, 0),
        Point3(1, 0, 1),
        Point3(0, 0, 1),
        Point3(0, 1, 1),
        Point3(1, 1, 1),
        Point3(1, 1, 0),
        Point3(0, 1, 0),
    ]

    block_id_map: typing.ClassVar[dict[Point3, int]] = {
        Point3(0, 0, 0): 0,
        Point3(1, 0, 0): 1,
        Point3(1, 0, 1): 2,
        Point3(0, 0, 1): 3,
        Point3(0, 1, 1): 4,
        Point3(1, 1, 1): 5,
        Point3(1, 1, 0): 6,
        Point3(0, 1, 0): 7,
    }

    transform_map: typing.ClassVar[list[Transform]] = [
        CompositeTransform(
            [Rotation(vec3(0, 0, -1), np.pi / 2), Rotation(vec3(0, -1, 0), np.pi / 2)]
        ),
        CompositeTransform(
            [Rotation(vec3(0, 0, 1), np.pi / 2), Rotation(vec3(1, 0, 0), np.pi / 2)]
        ),
        CompositeTransform(
            [Rotation(vec3(0, 0, 1), np.pi / 2), Rotation(vec3(1, 0, 0), np.pi / 2)]
        ),
        CompositeTransform(
            [Translation(vec3(1, 0, 1)), Rotation(vec3(0, 1, 0), np.pi)]
        ),
        CompositeTransform(
            [Translation(vec3(1, 0, 1)), Rotation(vec3(0, 1, 0), np.pi)]
        ),
        CompositeTransform(
            [
                Translation(vec3(0, 1, 1)),
                Rotation(vec3(0, 0, -1), np.pi / 2),
                Rotation(vec3(-1, 0, 0), np.pi / 2),
            ]
        ),
        CompositeTransform(
            [
                Translation(vec3(0, 1, 1)),
                Rotation(vec3(0, 0, -1), np.pi / 2),
                Rotation(vec3(-1, 0, 0), np.pi / 2),
            ]
        ),
        CompositeTransform(
            [
                Translation(vec3(1, 1, 0)),
                Rotation(vec3(0, 0, 1), np.pi / 2),
                Rotation(vec3(0, -1, 0), np.pi / 2),
            ]
        ),
    ]

    @classmethod
    def __base_point(cls, block_id: int, order: int) -> Point3:
        p = cls.block_map[block_id]
        return Point3(p.x << order, p.y << order, p.z << order)

    def encode(self, point: Point3) -> int:
        # print(f'encode: {point}')
        curr_order = self.order
        curr_point = point
        encoded_index = 0
        while curr_order > 0:
            curr_x = curr_point.x >> (curr_order - 1)
            curr_y = curr_point.y >> (curr_order - 1)
            curr_z = curr_point.z >> (curr_order - 1)
            block_id = self.block_id_map[Point3(curr_x, curr_y, curr_z)]
            encoded_index += block_id * (1 << (3 * (curr_order - 1)))
            base_point = self.__base_point(block_id, curr_order - 1)
            relative_point = curr_point - base_point
            # scale is (1 << (curr_order - 1)) - 1
            # ((1 << (curr_order - 1)) - 1)
            transformed_point = Point3.from_numpy(
                self.transform_map[block_id].apply_inverse(
                    relative_point.to_numpy(), scale=((1 << (curr_order - 1)) - 1)
                )
            )
            # print(
            # f"block_id = {block_id}, encoded_index = {encoded_index}, relative_point = {relative_point}, transformed_point = {transformed_point}"
            # )
            # convert to next order
            # curr_point =
            curr_point = transformed_point
            curr_order -= 1
        return encoded_index

    def decode(self, index: int) -> Point3:
        curr_order = 0
        point = Point3(0, 0, 0)
        while curr_order < self.order:
            block_id = index & 0b111
            index >>= 3
            base_point = self.__base_point(block_id, curr_order)
            # convert to next order
            point = (
                Point3.from_numpy(
                    self.transform_map[block_id].apply(
                        point.to_numpy(), scale=((1 << curr_order) - 1)
                    )
                )
                + base_point
            )
            curr_order += 1
        return point


class MortonZCurve(Curve3D):
    def __init__(self, order: int):
        self.order = order
        # index = x_bitN|y_bitN|z_bitN|x_bitN-1|y_bitN-1|z_bitN-1|...|x_bit0|y_bit0|z_bit0

    def encode(self, point: Point3) -> int:
        index = 0
        curr_order = self.order
        for i in range(curr_order):
            index |= ((point.x >> i) & 1) << (3 * i)
            index |= ((point.y >> i) & 1) << (3 * i + 1)
            index |= ((point.z >> i) & 1) << (3 * i + 2)
        return index

    def decode(self, index: int) -> Point3:
        x = 0
        y = 0
        z = 0
        curr_order = self.order
        for i in range(curr_order):
            x |= ((index >> (3 * i)) & 1) << i
            y |= ((index >> (3 * i + 1)) & 1) << i
            z |= ((index >> (3 * i + 2)) & 1) << i
        return Point3(x, y, z)


order = 2

hilbert_curve = HilbertCurve(order)

pnt_seq = []

for i in range(2 ** (3 * order)):
    p = hilbert_curve.decode(i)
    print(f"map {p} to {i}")
    assert hilbert_curve.encode(p) == i
    pnt_seq.append(p.to_numpy())

plot_seq(pnt_seq, show_index=True)

morton_curve = MortonZCurve(order)
pnt_seq = []

for i in range(2 ** (3 * order)):
    p = morton_curve.decode(i)
    print(f"map {p} to {i}")
    assert morton_curve.encode(p) == i
    pnt_seq.append(p.to_numpy())

plot_seq(pnt_seq,show_index=True)

plt.show()