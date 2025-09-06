'use strict';

const fs = require('node:fs');
const path = require('node:path')

hexo.extend.filter.register("after_init", function () {
  const { log } = hexo;
  const alert_css_path = 'node_modules/remark-github-blockquote-alert/alert.css';
  const target_path = 'source/_data/styles.styl';
  const target_dir = path.dirname(target_path);
  log.debug(`Copy ${alert_css_path} to ${target_path}`);
  if (!fs.existsSync(target_dir)) {
    log.debug(`Create dir ${target_dir}`)
    fs.mkdirSync(target_dir);
  }
  fs.copyFileSync(alert_css_path, target_path);
});