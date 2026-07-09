import { BrowserWindow, app } from 'electron';
import { join } from 'node:path';
import { readFileSync } from 'node:fs';

function getQRCodePath(): string {
  const possiblePaths = [
    join(__dirname, '..', '..', 'resources', 'images', 'qrcode_yxzk.jpg'),
    join(app.getAppPath(), 'resources', 'images', 'qrcode_yxzk.jpg'),
    join(process.resourcesPath || '', 'images', 'qrcode_yxzk.jpg'),
  ];
  for (const p of possiblePaths) {
    try {
      readFileSync(p);
      return p;
    } catch {
      continue;
    }
  }
  return possiblePaths[0];
}

let customerWindow: BrowserWindow | null = null;

export function showCustomerService(): void {
  if (customerWindow && !customerWindow.isDestroyed()) {
    customerWindow.focus();
    return;
  }

  customerWindow = new BrowserWindow({
    width: 380,
    height: 500,
    resizable: false,
    minimizable: false,
    fullscreenable: false,
    title: '逸寻智库',
    autoHideMenuBar: true,
    webPreferences: {
      sandbox: true,
    },
  });

  const qrPath = getQRCodePath();
  const html = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  background: #fff;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  min-height: 100vh; padding: 24px; text-align: center;
}
img {
  width: 258px; height: 258px;
  border-radius: 12px; margin-bottom: 20px;
}
h2 { font-size: 18px; font-weight: 600; color: #1a1a1a; margin-bottom: 8px; }
p { font-size: 14px; color: #666; line-height: 1.6; }
.footer { margin-top: 24px; font-size: 12px; color: #999; }
</style>
</head>
<body>
  <img src="file://${qrPath}" alt="逸寻智库二维码" />
  <h2>逸寻智库</h2>
  <p>扫码关注公众号<br/>获取龙虾管家最新资讯与支持</p>
  <div class="footer">青岛火一五信息科技有限公司</div>
</body>
</html>`;

  customerWindow.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(html)}`);

  customerWindow.on('closed', () => {
    customerWindow = null;
  });
}
