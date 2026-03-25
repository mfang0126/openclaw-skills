const https = require('https');
const fs = require('fs');
const path = require('path');

// 配置
const WP_URL = 'mingfang.tech';
const WP_USER = 'mfang0126@gmail.com';
const WP_PASS = process.env.WP_PASS || 'X5YpiLJQAAbZyayYYfEXyw7O';

// 添加 CSS 样式到文章内容
const CUSTOM_CSS = `<!-- wp:html -->
<style>
/* WordPress 文章样式优化 */
.wp-content-wrapper {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  line-height: 1.8;
  color: #333;
}

.wp-content-wrapper h1 {
  font-size: 2em;
  margin: 1.5em 0 0.8em;
  padding-bottom: 0.3em;
  border-bottom: 2px solid #e0e0e0;
}

.wp-content-wrapper h2 {
  font-size: 1.5em;
  margin: 1.5em 0 0.6em;
  padding-bottom: 0.2em;
  border-bottom: 1px solid #e8e8e8;
  color: #2c3e50;
}

.wp-content-wrapper h3 {
  font-size: 1.25em;
  margin: 1.2em 0 0.5em;
  color: #34495e;
}

.wp-content-wrapper h4 {
  font-size: 1.1em;
  margin: 1em 0 0.4em;
  color: #555;
}

/* 表格样式 */
.wp-content-wrapper table {
  width: 100%;
  border-collapse: collapse;
  margin: 1.5em 0;
  background: #fff;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.wp-content-wrapper th,
.wp-content-wrapper td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid #e0e0e0;
}

.wp-content-wrapper th {
  background: #f8f9fa;
  font-weight: 600;
  color: #2c3e50;
  border-top: 2px solid #3498db;
}

.wp-content-wrapper tr:hover {
  background: #f8f9fa;
}

/* 代码块样式 */
.wp-content-wrapper pre {
  background: #f4f4f4;
  border: 1px solid #ddd;
  border-left: 4px solid #3498db;
  border-radius: 4px;
  padding: 16px;
  overflow-x: auto;
  font-family: 'Monaco', 'Menlo', monospace;
  font-size: 0.9em;
  line-height: 1.5;
  margin: 1.5em 0;
}

.wp-content-wrapper code {
  background: #f0f0f0;
  padding: 2px 6px;
  border-radius: 3px;
  font-family: 'Monaco', 'Menlo', monospace;
  font-size: 0.9em;
  color: #c0392b;
}

.wp-content-wrapper pre code {
  background: none;
  padding: 0;
  color: inherit;
}

/* 引用块样式 */
.wp-content-wrapper blockquote {
  border-left: 4px solid #3498db;
  margin: 1.5em 0;
  padding: 1em 1.5em;
  background: #f8f9fa;
  color: #555;
  font-style: italic;
}

.wp-content-wrapper blockquote p {
  margin: 0;
}

/* 列表样式 */
.wp-content-wrapper ul,
.wp-content-wrapper ol {
  margin: 1em 0;
  padding-left: 2em;
}

.wp-content-wrapper li {
  margin: 0.5em 0;
}

/* 分割线 */
.wp-content-wrapper hr {
  border: none;
  border-top: 2px solid #e0e0e0;
  margin: 2em 0;
}

/* 强调 */
.wp-content-wrapper strong {
  color: #2c3e50;
  font-weight: 600;
}

.wp-content-wrapper em {
  color: #555;
}

/* 链接 */
.wp-content-wrapper a {
  color: #3498db;
  text-decoration: none;
  border-bottom: 1px dotted #3498db;
}

.wp-content-wrapper a:hover {
  border-bottom: 1px solid #3498db;
}

/* 勾选框 */
.wp-content-wrapper input[type="checkbox"] {
  margin-right: 8px;
}

/* 响应式 */
@media (max-width: 768px) {
  .wp-content-wrapper table {
    font-size: 0.9em;
  }
  
  .wp-content-wrapper th,
  .wp-content-wrapper td {
    padding: 8px 12px;
  }
}
</style>
<div class="wp-content-wrapper">
<!-- /wp:html -->
`;

const CSS_CLOSING = '<!-- wp:html --></div><!-- /wp:html -->';

// 简单的 Markdown 转 HTML
function markdownToHtml(md) {
  let html = md;
  
  // 处理代码块（先处理，避免被其他规则干扰）
  const codeBlocks = [];
  html = html.replace(/```(\w+)?\n([\s\S]*?)```/g, (match, lang, code) => {
    const id = codeBlocks.length;
    codeBlocks.push({ lang, code });
    return `<!--CODE_BLOCK_${id}-->`;
  });
  
  // 行内代码
  html = html.replace(/`([^`]+)`/g, '<code>$1</code>');
  
  // 标题
  html = html.replace(/^#### (.*$)/gim, '<h4>$1</h4>');
  html = html.replace(/^### (.*$)/gim, '<h3>$1</h3>');
  html = html.replace(/^## (.*$)/gim, '<h2>$1</h2>');
  html = html.replace(/^# (.*$)/gim, '<h1>$1</h1>');
  
  // 粗体和斜体
  html = html.replace(/\*\*\*(.*?)\*\*\*/g, '<strong><em>$1</em></strong>');
  html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
  html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');
  
  // 删除线
  html = html.replace(/~~(.*?)~~/g, '<del>$1</del>');
  
  // 引用块
  html = html.replace(/^> (.*$)/gim, '<blockquote>$1</blockquote>');
  
  // 图片
  html = html.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img alt="$1" src="$2" style="max-width:100%;height:auto;">');
  
  // 链接
  html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
  
  // 无序列表
  html = html.replace(/^\- (.*$)/gim, '<li>$1</li>');
  html = html.replace(/(<li>.*<\/li>\n)+/g, '<ul>$&</ul>');
  
  // 有序列表
  html = html.replace(/^\d+\. (.*$)/gim, '<li>$1</li>');
  html = html.replace(/(<li>.*<\/li>\n)+/g, (match) => {
    if (!match.includes('<ul>')) {
      return '<ol>' + match + '</ol>';
    }
    return match;
  });
  
  // 任务列表
  html = html.replace(/^\- \[ \] (.*$)/gim, '<li><input type="checkbox" disabled> $1</li>');
  html = html.replace(/^\- \[x\] (.*$)/gim, '<li><input type="checkbox" checked disabled> $1</li>');
  
  // 表格
  // 简化处理：检测表格行并转换
  const lines = html.split('\n');
  let result = [];
  let inTable = false;
  let tableLines = [];
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    
    // 检测表格行 (| 开头或包含 | )
    if (line.startsWith('|') || (line.includes('|') && !inTable && line.trim().startsWith('|'))) {
      if (!inTable) {
        inTable = true;
        tableLines = [];
      }
      tableLines.push(line);
    } else {
      if (inTable) {
        // 处理表格
        result.push(convertTable(tableLines));
        inTable = false;
        tableLines = [];
      }
      result.push(line);
    }
  }
  
  if (inTable) {
    result.push(convertTable(tableLines));
  }
  
  html = result.join('\n');
  
  // 恢复代码块
  codeBlocks.forEach((block, id) => {
    const lang = block.lang ? ` class="language-${block.lang}"` : '';
    const code = escapeHtml(block.code);
    html = html.replace(`<!--CODE_BLOCK_${id}-->`, `<pre><code${lang}>${code}</code></pre>`);
  });
  
  // 分割线
  html = html.replace(/^---$/gim, '<hr>');
  html = html.replace(/^\*\*\*$/gim, '<hr>');
  
  // 段落（简单处理）
  html = html.replace(/\n\n/g, '</p>\n\n<p>');
  html = '<p>' + html + '</p>';
  
  // 清理空段落
  html = html.replace(/<p><\/p>/g, '');
  html = html.replace(/<p>(<h[1-6]>)/g, '$1');
  html = html.replace(/(<\/h[1-6]>)<\/p>/g, '$1');
  html = html.replace(/<p>(<blockquote>)/g, '$1');
  html = html.replace(/(<\/blockquote>)<\/p>/g, '$1');
  html = html.replace(/<p>(<pre>)/g, '$1');
  html = html.replace(/(<\/pre>)<\/p>/g, '$1');
  html = html.replace(/<p>(<table>)/g, '$1');
  html = html.replace(/(<\/table>)<\/p>/g, '$1');
  html = html.replace(/<p>(<[ou]l>)/g, '$1');
  html = html.replace(/(<\/[ou]l>)<\/p>/g, '$1');
  html = html.replace(/<p><hr>/g, '<hr>');
  html = html.replace(/<hr><\/p>/g, '<hr>');
  
  return html;
}

// 转换表格
function convertTable(lines) {
  if (lines.length < 2) return lines.join('\n');
  
  let html = '<table>\n<thead>\n<tr>';
  
  // 表头
  const headers = lines[0].split('|').filter(cell => cell.trim() !== '');
  headers.forEach(header => {
    html += `<th>${header.trim()}</th>`;
  });
  html += '</tr>\n</thead>\n<tbody>\n';
  
  // 跳过分隔行 (|---|---|)
  for (let i = 2; i < lines.length; i++) {
    const cells = lines[i].split('|').filter(cell => cell.trim() !== '');
    if (cells.length > 0) {
      html += '<tr>';
      cells.forEach(cell => {
        html += `<td>${cell.trim()}</td>`;
      });
      html += '</tr>\n';
    }
  }
  
  html += '</tbody>\n</table>';
  return html;
}

// HTML 转义
function escapeHtml(text) {
  const map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  };
  return text.replace(/[&<>"']/g, m => map[m]);
}

// 主函数
async function publish() {
  const args = process.argv.slice(2);
  
  if (args.length < 1) {
    console.log('用法: node publish.js <markdown文件> [draft|publish] [标题]');
    console.log('示例: node publish.js article.md draft "文章标题"');
    process.exit(1);
  }
  
  const filePath = args[0];
  const status = args[1] || 'draft';
  const customTitle = args[2];
  
  // 检查文件
  if (!fs.existsSync(filePath)) {
    console.error(`❌ 文件不存在: ${filePath}`);
    process.exit(1);
  }
  
  console.log(`📝 读取文件: ${filePath}`);
  const markdown = fs.readFileSync(filePath, 'utf8');
  
  // 提取标题
  let title = customTitle;
  if (!title) {
    const titleMatch = markdown.match(/^# (.+)$/m);
    title = titleMatch ? titleMatch[1] : path.basename(filePath, '.md');
  }
  
  // 提取摘要（第一个 blockquote 或第一段）
  let excerpt = '';
  const excerptMatch = markdown.match(/> \*\*(.+?)\*\*/);
  if (excerptMatch) {
    excerpt = excerptMatch[1];
  } else {
    const firstPara = markdown.split('\n\n')[0].replace(/^# .+\n/, '').trim();
    if (firstPara && !firstPara.startsWith('---')) {
      excerpt = firstPara.substring(0, 200) + (firstPara.length > 200 ? '...' : '');
    }
  }
  
  console.log(`📋 标题: ${title}`);
  console.log(`📤 状态: ${status}`);
  
  // 转换为 HTML
  console.log('🔄 转换 Markdown 到 HTML...');
  const htmlContent = markdownToHtml(markdown);
  
  // 添加 CSS 包装
  let finalHtml = CUSTOM_CSS + htmlContent + CSS_CLOSING;
  
  // 清理被 <p> 包裹的 CSS 样式 - 强力清理
  // 清理 <p> 包裹的样式定义
  finalHtml = finalHtml.replace(/<p>(\.wp-content-wrapper[^{]*{[^}]*})<\/p>/g, '$1');
  finalHtml = finalHtml.replace(/<p>(\.wp-content-wrapper [^{]*{[^}]*})<\/p>/g, '$1');
  // 清理 <p> 包裹的选择器（没有大括号的情况）
  finalHtml = finalHtml.replace(/<p>(\.wp-content-wrapper[^{]*)<\/p>/g, '$1');
  // 清理 <p> 包裹的注释
  finalHtml = finalHtml.replace(/<p>(\/\*[^*]*\*+(?:[^/*][^*]*\*+)*\/)<\/p>/g, '$1');
  // 清理 <p> 包裹的 style 标签
  finalHtml = finalHtml.replace(/<p>(<style>[\s\S]*?<\/style>)<\/p>/g, '$1');
  // 清理 <p> 包裹的结束 div
  finalHtml = finalHtml.replace(/<p>(<\/div>)<\/p>/g, '$1');
  // 清理 CSS 规则之间多余的 <p></p>
  finalHtml = finalHtml.replace(/}(\s*)<p>(\s*\.)/g, '}$1$2');
  finalHtml = finalHtml.replace(/<\/p>\s*<p>/g, '');
  // 清理连续的 <p> 标签
  finalHtml = finalHtml.replace(/<p>\s*<\/p>/g, '');
  
  // 发布到 WordPress
  await publishToWordPress(title, finalHtml, excerpt, status);
}

// 发布到 WordPress
function publishToWordPress(title, content, excerpt, status) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({
      title: title,
      content: content,
      excerpt: excerpt,
      status: status
    });
    
    const auth = Buffer.from(`${WP_USER}:${WP_PASS}`).toString('base64');
    
    const options = {
      hostname: WP_URL,
      port: 443,
      path: '/wp-json/wp/v2/posts',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`,
        'Content-Length': Buffer.byteLength(postData)
      },
      timeout: 30000
    };
    
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          if (res.statusCode === 201) {
            console.log('\n✅ 发布成功！');
            console.log(`文章 ID: ${result.id}`);
            console.log(`标题: ${result.title.rendered}`);
            console.log(`状态: ${result.status}`);
            console.log(`链接: ${result.link}`);
            console.log(`编辑: https://${WP_URL}/wp-admin/post.php?post=${result.id}&action=edit`);
            resolve(result);
          } else {
            console.error('\n❌ 发布失败:', result.message);
            reject(result);
          }
        } catch (e) {
          console.error('\n❌ 解析错误:', e.message);
          reject(e);
        }
      });
    });
    
    req.on('error', (e) => {
      console.error('\n❌ 请求错误:', e.message);
      reject(e);
    });
    
    req.on('timeout', () => {
      console.error('\n❌ 请求超时');
      req.destroy();
      reject(new Error('Timeout'));
    });
    
    req.write(postData);
    req.end();
  });
}

// 运行
publish().catch(console.error);
