import chalk from 'chalk'
import { webContents, shell, BrowserWindow } from 'electron'
import WindowManager from './window'
import { map } from 'lodash'
import path from 'path'

const stringify = (str) => {
  if (typeof str === 'string') {
    return str
  }
  if (str.toString().startsWith('[object ')) {
    str = JSON.stringify(str)
  } else {
    str = str.toString()
  }
  return str
}


export const remoteStringify = JSON.stringify

export function log(...str) {
  // eslint-disable-next-line no-console
  console.log("[INFO] ", ...map(str, stringify))
}

export function warn(...str) {
  console.warn(chalk.yellow("[WARN] ", ...map(str, stringify)))
}

export function error(...str) {
  console.error(chalk.red.bold("[ERROR] ", ...map(str, stringify)))
}

export function setBounds(options) {
  return global.mainWindow.setBounds(options)
}

export function getBounds() {
  return global.mainWindow.getBounds()
}

export function stopFileNavigate(id) {
  webContents.fromId(id).addListener('will-navigate', (e, url) => {
    if (url.startsWith('file')) {
      e.preventDefault()
    }
  })
}

const set = new Set()

export function stopFileNavigateAndHandleNewWindowInApp(id) {
  webContents.fromId(id).addListener('will-navigate', (e, url) => {
    if (url.startsWith('file')) {
      e.preventDefault()
    }
  })
  webContents.fromId(id).addListener('new-window',(e, url, frameName, disposition, options, additionalFeatures) => {
    if (!set.has(url)) {
      const win = WindowManager.createWindow({
        realClose: true,
        navigatable: true,
        nodeIntegration: false,
      })
      win.loadURL(url)
      win.show()
      set.add(url)
      setTimeout(() => {
        set.delete(url)
      }, 1000)
    }
    e.preventDefault()
  })
}

export function stopNavigateAndHandleNewWindow(id) {
  webContents.fromId(id).addListener('will-navigate', (e, url) => {
    e.preventDefault()
    if (url.startsWith('http')) {
      shell.openExternal(url)
    }
  })
  webContents.fromId(id).addListener('new-window', (e, url, frameName, disposition, options, additionalFeatures) => {
    e.preventDefault()
    if (url.startsWith('http')) {
      shell.openExternal(url)
    } else if (frameName.startsWith('plugin')) {
      options.resizable = true
      if (frameName.startsWith('plugin[kangame]')) {
        options.useContentSize = true
      }
      if (url.startsWith('chrome')) {
        options.frame = true
      }
      options = {
        ...options,
        minWidth: 200,
        minHeight: 200,
        backgroundColor: process.platform === 'darwin' ? '#00000000' : '#E62A2A2A',
        titleBarStyle: process.platform === 'darwin' && Number(require('os').release().split('.')[0]) >= 17 ? 'hidden' : null,
        autoHideMenuBar: true,
        preload: path.join(global.ROOT, 'sentry.js'),
      }
      e.newGuest = new BrowserWindow(options)
    }
  })
}
