#!/usr/bin/env bash

source "./public.bash"

# Current User
user=$(id -un)

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo ""
headline " Let's secure your Mac and install basic applications."
echo ""
echo "Modifying settings for user: $user."
# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
if [ $(sudo -n uptime 2>&1|grep "load"|wc -l) -eq 0 ]
then
    step "Some of these settings are system-wide, therefore we need your permission."
    sudo -v
    echo ""
fi

step "Setting your computer name (as done via System Preferences → Sharing)."
echo "What would you like it to be? $bold"
read computer_name
echo "$reset"
run sudo scutil --set ComputerName "'$computer_name'"
run sudo scutil --set HostName "'$computer_name'"
run sudo scutil --set LocalHostName "'$computer_name'"
run sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "'$computer_name'"

# Files
echo "Enable bash autocomplete"
run sudo cp ./files/.inputrc ~/.inputrc

echo "Disable startup chime sound."
run sudo nvram SystemAudioVolume=" "

# UX And Performance Improvements
echo "Disable sudden motion sensor. (Not useful for SSDs)."
run sudo pmset -a sms 0

echo "Use 24-hour time. Use the format EEE MMM d  H:mm:ss"
run defaults write com.apple.menuextra.clock DateFormat -string 'EEE MMM d  H:mm:ss'

echo "Disable press-and-hold for keys in favor of key repeat."
run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo "Set a fast keyboard repeat rate, after a good initial delay."
run defaults write NSGlobalDomain KeyRepeat -int 1
run defaults write NSGlobalDomain InitialKeyRepeat -int 25

echo "Disable auto-correct."
run defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "Speed up mission control animations."
run defaults write com.apple.dock expose-animation-duration -float 0.1

echo "Remove the auto-hiding dock delay."
run defaults write com.apple.dock autohide-delay -int 0

echo "Use the dark theme."
run defaults write ~/Library/Preferences/.GlobalPreferences AppleInterfaceStyle -string "Dark"

echo "Save screenshots in PNG format."
run defaults write com.apple.screencapture type -string png

echo "Save screenshots to user screenshots directory instead of desktop."
run mkdir ~/screenshots
run defaults write com.apple.screencapture location -string ~/screenshots

echo "Disable shadow in screenshots."
defaults write com.apple.screencapture disable-shadow -bool true

echo "Disable menu transparency."
run defaults write com.apple.universalaccess reduceTransparency -int 1

echo "Turn off increased contrast. macOS 10.14 causes ugly white borders."
run defaults write com.apple.universalaccess increaseContrast -int 0

echo "Disable mouse enlargement with jiggle."
run defaults write ~/Library/Preferences/.GlobalPreferences CGDisableCursorLocationMagnification -bool true

echo "Disable annoying UI error sounds."
run defaults write com.apple.systemsound com.apple.sound.beep.volume -int 0
run defaults write com.apple.sound.beep feedback -int 0
run defaults write com.apple.systemsound com.apple.sound.uiaudio.enabled -int 0
run osascript -e 'set volume alert volume 0'

echo "Show all filename extensions."
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Disable the warning when changing a file extension."
run defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "Use list view in all Finder windows by default."
run defaults write com.apple.finder FXPreferredViewStyle -string '"Nlsv"'

echo "Show the ~/Library folder."
run chflags nohidden ~/Library

echo "Show the /Volumes folder."
run sudo chflags nohidden /Volumes

echo "Show hidden files (whose name starts with dot) in finder."
run defaults write com.apple.finder AppleShowAllFiles -int 1

echo "Show full file path in finder windows."
run defaults write _FXShowPosixPathInTitle com.apple.finder -int 1

echo "Don't write DS_Store files to network shares."
run defaults write DSDontWriteNetworkStores com.apple.desktopservices -int 1

echo "Don't ask to use external drives as a Time Machine backup."
run defaults write DoNotOfferNewDisksForBackup com.apple.TimeMachine -int 1

echo "Disable natural scrolling."
run defaults write ~/Library/Preferences/.GlobalPreferences com.apple.swipescrolldirection -bool false

echo "Always show scrollbars."
run defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

echo "Expand save panel by default."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo "Expand print panel by default."
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "Disable automatic capitalization."
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

echo "Disable smart dashes."
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "Disable automate period substitution."
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

echo "Disable smart quotes."
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

echo "Enable subpixel font rendering on non-Apple LCDs."
# Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
defaults write NSGlobalDomain AppleFontSmoothing -int 1

# Security And Privacy Improvements
echo "Disable Safari from auto-filling sensitive data."
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillCreditCardData -bool false
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillFromAddressBook -bool false
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillMiscellaneousForms -bool false
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillPasswords -bool false

echo "Enable Do Not Track in Safari."
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

echo "Disable Safari from automatically opening files."
run defaults write ~/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads -bool false

echo "Always block cookies and local storage in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari BlockStoragePolicy -bool false

echo "Enable Safari warnings when visiting fradulent websites."
run defaults write ~/Library/Preferences/com.apple.Safari WarnAboutFraudulentWebsites -bool true

echo "Disable javascript in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptEnabled -bool false
run defaults write ~/Library/Preferences/com.apple.Safari WebKitJavaScriptEnabled -bool false

echo "Block popups in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false
run defaults write ~/Library/Preferences/com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false

echo "Disable plugins and extensions in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2WebGLEnabled -bool false
run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false
run defaults write ~/Library/Preferences/com.apple.Safari WebKitPluginsEnabled -bool false
run defaults write ~/Library/Preferences/com.apple.Safari ExtensionsEnabled -bool false
run defaults write ~/Library/Preferences/com.apple.Safari PlugInFirstVisitPolicy PlugInPolicyBlock
run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
run defaults write ~/Library/Preferences/com.apple.Safari WebKitJavaEnabled -bool false

echo "Safari should treat SHA-1 certificates as insecure."
run defaults write ~/Library/Preferences/com.apple.Safari TreatSHA1CertificatesAsInsecure -bool true

echo "Disable pre-loading websites with high search rankings."
run defaults write ~/Library/Preferences/com.apple.Safari PreloadTopHit -bool false

echo "Disable Safari search engine suggestions."
run defaults write ~/Library/Preferences/com.apple.Safari SuppressSearchSuggestions -bool true

echo "Enable Do-Not-Track HTTP header in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari SendDoNotTrackHTTPHeader -bool true

echo "Disable pdf viewing in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari WebKitOmitPDFSupport -bool true

echo "Display full website addresses in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari ShowFullURLInSmartSearchField -bool true

echo "Disable loading remote content in emails in Apple Mail."
run defaults write ~/Library/Preferences/com.apple.mail-shared DisableURLLoading -bool true

echo "Send junk mail to the junk mail box in Apple Mail."
run defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail JunkMailBehavior -int 2

echo "Disable spotlight universal search (don't send info to Apple)."
run defaults write com.apple.safari UniversalSearchEnabled -int 0

echo "Disable Spotlight Suggestions, Bing Web Search, and other leaky data."
run python ./fix_leaky_data.py

echo "Disable Captive Portal Hijacking Attack."
run defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false

echo "Set screen to lock as soon as the screensaver starts."
run defaults write com.apple.screensaver askForPassword -int 1
run defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "Don't default to saving documents to iCloud."
run defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "Disable crash reporter."
run defaults write com.apple.CrashReporter DialogType none

echo "Enable Stealth Mode. Computer will not respond to ICMP ping requests or connection attempts from a closed TCP/UDP port."
run defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true

echo "Enable AirDrop over Ethernet."
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

echo "Set all network interfaces to use Cloudflare DNS (1.1.1.1)."
run bash ./use_cloudflare_dns.sh

echo "Disable wake on network access."
run systemsetup -setwakeonnetworkaccess off

echo "Disable Bonjour multicast advertisements."
run defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES

# This is disabled by default, but sometimes people turn it on and forget to turn it back off again.
echo "Turn off remote desktop access."
run sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -configure -access -off

echo "Enable Mac App Store automatic updates."
run defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

echo "Check for Mac App Store updates daily."
run defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo "Download Mac App Store updates in the background."
run defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

echo "Install Mac App Store system data files & security updates."
run defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

echo "Turn on Mac App Store auto-update."
run defaults write com.apple.commerce AutoUpdate -bool true

# Blocklists

echo "Block all Facebook domains."
if ! grep --quiet facebook /etc/hosts; then
    run cat block_facebook | sudo tee -a /etc/hosts
else
    echo "${dim}▹ Facebook domains already blocked. $reset"
fi

# Download Packaged Software
# Some software comes packaged directly from the vendor
# Eventually we'll automate the installs of each of these
# But the biggest challenege is just remembering
# Which apps you need to download, so let's do that for now

download_file "https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US" "firefox-latest.dmg"

download_file "https://downloads.1password.com/mac/1Password.zip" "1password-latest.pkg"

download_file "https://discordapp.com/api/download?platform=osx" "discord-latest.dmg"

download_file "https://dl-portal.iina.io/IINA.v1.3.5.dmg" "IINA-latest.dmg"

download_file "https://cdn-fastly.obsproject.com/downloads/obs-studio-31.0.2-macos-apple.dmg" "obs-mac-31.0.2-installer.pkg"

download_file "https://www.kaleidoscopeapp.com/download" "kaleidoscope-latest.zip"

download_file "https://d2oxtzozd38ts8.cloudfront.net/audiohijack/download/AudioHijack.zip" "AudioHijack.zip"

download_file "https://cdn.rogueamoeba.com/loopback/download/Loopback.zip" "Loopback-latest.zip"

download_file "https://desktop-release.notion-static.com/Notion-4.7.2-universal.dmg" "Notion-4.7.2-universal.dmg"

download_file "https://s3.us-west-2.amazonaws.com/calendar-desktop-release.notion-static.com/Notion%20Calendar-1.130.0-universal.dmg" "Notion-Calendar-1.130.0-universal.dmg"

download_file "https://desktop.linear.app/mac" "linear-latest.dmg"

download_file "https://files.tableplus.com/macos/600/TablePlus.dmg" "TablePlus-600.dmg"
# Blackmagic uses expiring keys to force you through their registration dialog
# *sigh* Manual download for now I guess... https://sw.blackmagicdesign.com/DesktopVideo/v11.2/Blackmagic_Desktop_Video_Macintosh_11.2.zip

# Install Applications

# Note: Before installing Homebrew, set the following settings in your .bash_profile for increased privacy.
# export HOMEBREW_NO_ANALYTICS=1
# export HOMEBREW_NO_INSECURE_REDIRECT=1
echo "Install Homebrew."
which -s brew
if [[ $? != 0 ]] ; then
    run '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
else
    run brew update
fi

echo "Install and configure git."
run brew install git
run git config --global user.email "echohack@users.noreply.github.com"
git config --global user.name "echohack"

echo "Prevent iTunes from taking backups of iPhone."
run defaults write com.apple.iTunes DeviceBackupsDisabled -bool true

echo "Install jq."
run brew install jq

echo "Install mas (Mac App Store Command Line)."
run brew install mas

echo "Prevent Google Chrome from Syncing automatically."
run defaults write com.google.Chrome SyncDisabled -bool true
run defaults write com.google.Chrome RestrictSigninToPattern -string ".*@example.com"

echo "Install Raycast."
run brew install --cask raycast

echo "Install Shadowfox (dark theme for Firefox)."
run brew install srkomodo/tap/shadowfox-updater
# This requires some gui interaction and firefox pre-installed...
# shadowfox-updater -generate-uuids -profile-index 0 -set-dark-theme

echo "Install youtube-dl."
run brew install youtube-dl
run brew upgrade youtube-dl
run brew install ffmpeg
run brew upgrade ffmpeg

echo "Install exercism CLI."
run brew install exercism
run brew upgrade exercism

echo "Install shellcheck."
run brew install shellcheck

echo "Install pre-commit"
run brew install pre-commit

echo "Install Warp CLI."
run brew install --cask warp

echo "Install OrbStack."
run brew install orbstack

echo "Install docker."
run brew cask install docker

echo "Install VLC."
run brew cask install vlc

echo "Install LiceCap."
run brew cask install licecap

echo "Install Visual Studio Code."
run brew cask install visual-studio-code

echo "Install Visual Studio Code Extensions."
vscode_install_ext(){
    run code --install-extension $@
}
vscode_install_ext bungcip.better-toml
vscode_install_ext mauve.terraform
vscode_install_ext ms-python.python
vscode_install_ext ms-vscode.vscode-typescript-tslint-plugin
vscode_install_ext redhat.vscode-yaml
vscode_install_ext rust-lang.rust

echo "Install npm."
run brew install npm

# Trust a curl | bash? Why not.
echo "Install rust using Rustup."
rustc --version
if [[ $? != 0 ]] ; then
    run curl https://sh.rustup.rs -sSf | sh
    run rustup update
fi

# Install all the Mac App Store applications using mas. https://github.com/mas-cli/mas
mac_app_login=$(mas account | grep @)
if [ -z "$mac_app_login" ] ; then
    chapter "Let's install Mac App Store applications. What is your Mac App Store email login? $bold"
    read mac_app_login
    run mas signin $mac_app_login
fi

echo "Install Decompressor."
run mas install 1033480833

echo "Install HEIC Converter."
run mas install 1294126402

echo "Install Keynote."
run mas install 409183694

echo "Install Pixelmator Pro."
run mas install 1289583905

echo "Install Slack."
run mas install 803453959

echo "Install Things3."
run mas install 904280696

# Final updates
echo "Upgrade any Mac App Store applications."
run mas upgrade

echo "Run one final check to make sure software is up to date."
run softwareupdate -i -a

run killall Dock
run killall Finder
run killall SystemUIServer

chapter "Some settings will not take effect until you restart your computer."
headline " Your Mac is setup and ready!"


#https://itunes.apple.com/us/app/pixelmator-pro/id1289583905?mt=12
