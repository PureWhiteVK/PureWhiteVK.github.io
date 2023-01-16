// code modified from https://github.com/wzpan/hexo-renderer-pandoc/blob/master/index.js

'use strict';

const spawn = require('cross-spawn');
const path = require('node:path')
const { CacheStream } = require('hexo-util');
const assert = require('node:assert');
const { yellow } = require('picocolors');

hexo.config.pandoc = Object.assign({
    pandoc_bin: 'pandoc',
    math_engine: 'mathjax',
    markdown_mode: 'gfm',
    filters: [],
    lua_filters: [],
    extra: [],
}, hexo.config.pandoc);

// must have the `?.lua` specified!
const pandoc_env = { ...process.env, LUA_PATH: path.join(process.cwd(), 'lua', '?.lua') };

const argument = (name, value = undefined) => {
    if (value) {
        return `--${name}=${value}`;
    }
    return `--${name}`;
};

const is_string = obj => typeof (obj) === 'string';

const is_array = obj => Array.isArray(obj);

const is_object = obj => typeof (obj) === 'object';

const get_cache = (stream, encoding) => {
    const buf = stream.getCache();
    stream.destroy();
    if (!encoding) return buf;
    return buf.toString(encoding);
}

const renderer = (data, options) => {
    const { log } = hexo;

    let config = hexo.config.pandoc;

    const filters = [];
    const lua_filters = [];
    const extra = [argument('metadata', 'pagetitle:ignored')];
    // To satisfy pandoc's requirement that html5 must have a title.
    // Since the markdown file is only rendered as body part,
    // the title is never used and thus does not matter
    const pandoc_bin = config.pandoc_bin;
    const math_engine = argument(config.math_engine);
    const markdown_mode = config.markdown_mode;

    if (!is_array(config.filters)) {
        config.filters = [config.filters];
    }

    if (!is_array(config.lua_filters)) {
        config.lua_filters = [config.lua_filters];
    }

    if (!is_array(config.extra)) {
        config.extra = [config.extra];
    }

    config.filters.forEach((filter) => {
        filters.push(argument('filter', filter));
    });

    config.lua_filters.forEach((filter) => {
        lua_filters.push(argument('lua-filter', filter));
    });

    config.extra.forEach((item) => {
        if (is_string(item)) {
            extra.push(argument(item));
        } else if (is_object(item)) {
            assert(Object.keys(item).length === 1, `item in extra must be a key-value tuple or string`);
            const [key, value] = Object.entries(item)[0];
            if (is_array(value)) {
                value.forEach((v) => {
                    extra.push(argument(key, v));
                });
            } else {
                extra.push(argument(key, value));
            }
        } else {
            throw new TypeError(`unknown extra config for pandoc: ${item}`);
        }
    });

    const POST_MODEL = hexo.model('Post');

    const source = data.path.substring(hexo.source_dir.length).replace(/\\/g, '/');

    const current_post = POST_MODEL.findOne({ source });

    if (current_post) {
        // manually add root path
        const post_path = `/${current_post.path}`;
        // the filename (xxx.md) may not correspond to title field in Markdown Front Matter
        const filename = path.basename(data.path, '.md');
        log.debug('Filename: %s', yellow(filename));
        // const title = current_post.title;
        extra.push(argument('metadata', `path:${post_path}`));
        extra.push(argument('metadata', `title:${filename}`));
    }

    // if we are rendering a post,
    // `data` has the key `path`
    // https://github.com/hexojs/hexo/blob/2ed17cd105768df379dad8bbbe4df30964fe8f2d/lib/hexo/post.js#L269
    // otherwise (e.g., rendering a tag),
    // `path` is not present in `data`.
    // https://github.com/hexojs/hexo/blob/2ed17cd105768df379dad8bbbe4df30964fe8f2d/lib/extend/tag.js#L173
    // https://github.com/hexojs/hexo/blob/a6dc0ea28dddad1b5f1bad7c6f86f1e0627b564a/lib/plugins/tag/blockquote.js#L64
    // are we rendering a standalone post?
    if (data.path) {
        // only apply template when rendering post, not tags
        if (config.template) {
            extra.push(argument('template', config.template, true));
        }
        // do not apply `--standalone`,
        // header/footer are to be added by Hexo
        // also set a metavariable to let concerned
        // pandoc filters know
        extra.push(argument('metadata', 'standalone:true'));
    } else {
        // or some thing to be embedded in a post,
        // like tags?
        extra.push(argument('metadata', 'standalone:false'));
    }

    const args = [
        argument('from', markdown_mode),
        argument('to', 'html5'),
        math_engine,
        ...extra,
        ...lua_filters,
        ...filters,
    ];

    log.debug('Pandoc command: %s', yellow(`${pandoc_bin} ${args.join(' ')}`));

    return new Promise((resolve, reject) => {
        const task = spawn(pandoc_bin, args, {
            env: pandoc_env,
            cwd: process.cwd()
        });
        const encoding = 'utf-8';

        const stdout_cache = new CacheStream();
        const stderr_cache = new CacheStream();

        if (task.stdout) {
            task.stdout.setEncoding(encoding);
            task.stdout.pipe(stdout_cache);
        }

        if (task.stderr) {
            task.stderr.setEncoding(encoding);
            task.stderr.pipe(stderr_cache);
        }

        if (task.stdin) {
            task.stdin.setEncoding(encoding);
            task.stdin.write(data.text);
            task.stdin.end();
        }

        task.on('close', code => {
            let stderr_msg = get_cache(stderr_cache, encoding);
            if (code) {
                const e = new Error(`pandoc process exited with code ${code}.${stderr_msg.length > 0 ? `\n${stderr_msg}` : ''}`);
                e.code = code;
                return reject(e);
            }
            if (stderr_msg.length > 0) {
                if (stderr_msg.endsWith('\n')) {
                    stderr_msg = stderr_msg.slice(0, -1)
                }
                log.debug(`Pandoc:\n%s`, yellow(stderr_msg));
            }
            resolve(get_cache(stdout_cache, encoding));
        });
    });
};

hexo.extend.renderer.register('md', 'html', renderer, true);
hexo.extend.renderer.register('markdown', 'html', renderer, true);
hexo.extend.renderer.register('mkd', 'html', renderer, true);
hexo.extend.renderer.register('mkdn', 'html', renderer, true);
hexo.extend.renderer.register('mdwn', 'html', renderer, true);
hexo.extend.renderer.register('mdtxt', 'html', renderer, true);
hexo.extend.renderer.register('mdtext', 'html', renderer, true);