# フォントのインストール/アンインストール用スクリプト
# 管理者権限の有無で以下のように処理内容を変化
# - 管理者: レジストリ登録
# - 非管理者: 専用ディレクトリへコピー
#
# 引数
#   1: インストールか否か($true or $false)
#   2: $dir(解凍したディレクトリへのパス)
#   3: フォント名を示すワイルドカード
#
# 環境変数
#   JP_FONT_DIR: ローカルインストール時に利用するディレクトリ
#                デフォルト値: "$HOME\JpFonts"

Param($is_install, $dir, $wildcard)

function is_admin {
    $admin = [security.principal.windowsbuiltinrole]::administrator
    $id = [security.principal.windowsidentity]::getcurrent()
    ([security.principal.windowsprincipal]($id)).isinrole($admin)
}
function can_use_local_font {
    $buildnum = Get-WmiObject Win32_OperatingSystem | Select-Object BuildNumber
    return $buildnum.BuildNumber -ge 17134
}
function warn {
    Param($msg)
    Write-Host "Warning: $msg" -ForegroundColor Red
}
function notice {
    Param($msg)
    Write-Host $msg -ForegroundColor Magenta
}
function log {
    Param($msg)
    Write-Host $msg -ForegroundColor White
}

function install_ttf_fonts {
    Param($fontdir, $target, $wildcard)
    $postfix = ' (TrueType)'
    Get-ChildItem $fontdir -Filter $wildcard | ForEach-Object {
        $font = $_.Name
        $extension = $_.Extension
        log "registering $font ..."
        New-ItemProperty -Path $regist `
                         -Name $font.Replace($extension, $postfix)`
                         -Value $font`
                         -Force `
            | Out-Null
        Copy-Item "$fontdir\$font" -Destination "$target\"
    }
}
function uninstall_ttf_fonts {
    Param($fontdir, $target, $wildcard)
    $postfix = ' (TrueType)'
    Get-ChildItem $fontdir -Filter $wildcard | ForEach-Object {
        $font = $_.Name
        $extension = $_.Extension
        log "unregistering $font ..."
        Remove-ItemProperty -Path $regist `
                            -Name $font.Replace($extension, $postfix) `
                            -ErrorAction SilentlyContinue `
                            -Force
        Remove-Item "$target\$font" -ErrorAction SilentlyContinue -Force
    }
}

function install_global {
    Param($dir, $wildcard)
    $regist = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
    install_ttf_fonts $dir $regist $wildcard
}
function uninstall_global {
    Param($dir, $wildcard)
    $regist = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
    uninstall_ttf_fonts $dir $regist $wildcard
}

function install_local {
    Param($dir, $wildcard)
    if (can_use_local_font) {
        # newer than 1803
        $local = [environment]::GetEnvironmentVariables('LocalAppData', 'User')
        install_ttf_fonts $dir "$local\Microsoft\Windows\Fonts" $wildcard
        notice "Font files has installed to local."
        notice "These fonts are only for you."
    } else {
        $pool = [environment]::GetEnvironmentVariable('JP_FONT_DIR', 'User')
        if ($pool -eq $null -or $pool -eq "") {
            $pool = "$HOME\JpFonts"
            [environment]::SetEnvironmentVariable('JP_FONT_DIR', "$HOME\JpFonts", 'User')
        }
        if (!(Test-Path $pool)) {
            notice "Make new directory '$pool' to access font files easily."
            New-Item -Path $pool -ItemType Directory -Force | Out-Null
        }
        Get-ChildItem $dir -Filter $wildcard | ForEach-Object {
            log "making copy of $_ ..."
            Copy-Item "$dir\$_" -Destination $pool
        }
        notice "Font files are copied to '$pool'."
        notice "You can access this directory from THE NEXT SESSION with these commands:"
        notice '- cmd.exe     explorer %JP_FONT_DIR%'
        notice '- PowerShell  explorer $env:JP_FONT_DIR'
    }
}
function uninstall_local {
    Param($dir, $wildcard)
    if (can_use_local_font) {
        # newer than 1803
        $local = [environment]::GetEnvironmentVariables('LocalAppData', 'User')
        uninstall_ttf_fonts $dir "$local\Microsoft\Windows\Fonts" $wildcard
    } else {
        $pool = [environment]::GetEnvironmentVariable('JP_FONT_DIR', 'User')
        if ($pool -eq $null) {
            warn "%JP_FONT_DIR% is not defined. End uninstallation."
            return 1
        }
        if (!(Test-Path $pool)) {
            warn "%JP_FONT_DIR% is not existing directory. End uninstallation."
            return 2
        }
        Get-ChildItem $dir -Filter $wildcard | ForEach-Object {
            log "deleting copy of $_ ..."
            Remove-Item "$pool\$($_.Name)" -ErrorAction SilentlyContinue -Force
        }
    }
}

# main
if (is_admin) {
    if ($is_install) {
        install_global   $dir $wildcard
    } else {
        uninstall_global $dir $wildcard
    }
} else {
    if ($is_install) {
        install_local    $dir $wildcard
    } else {
        uninstall_local  $dir $wildcard
    }
}

