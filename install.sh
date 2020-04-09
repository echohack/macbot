#!/usr/bin/env bash

# Current User
user=$(id -un)

# Script's color palette
reset="\033[0m"
highlight="\033[42m\033[97m"
dot="\033[33m▸ $reset"
dim="\033[2m"
bold="\033[1m"

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

headline() {
    printf "${highlight} %s ${reset}\n" "$@"
}

chapter() {
    echo "${highlight} $((count++)).) $@ ${reset}\n"
}

# Prints out a step, if last parameter is true then without an ending newline
step() {
    if [ $# -eq 1 ]
    then echo "${dot}$@"
    else echo "${dot}$@"
    fi
}

run() {
    echo "${dim}▹ $@ $reset"
    eval $@
}

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
run sudo cp ./files/inputrc ~/.inputrc

# UX And Performance Improvements
echo "Disable sudden motion sensor. (Not useful for SSDs)."
run sudo pmset -a sms 0

echo "Use 24-hour time. Use the format EEE MMM d  H:mm:ss"
run defaults write com.apple.menuextra.clock DateFormat -string 'EEE MMM d  H:mm:ss'

echo "Set a fast keyboard repeat rate, after a good initial delay."
run defaults write NSGlobalDomain KeyRepeat -int 1
run defaults write NSGlobalDomain InitialKeyRepeat -int 25

echo "Disable auto-correct."
run defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "Speed up mission control animations."
run defaults write com.apple.dock expose-animation-duration -float 0.1

echo "Remove the auto-hiding dock delay."
run defaults write com.apple.dock autohide-delay -int 0

echo "Save screenshots in PNG format."
run defaults write com.apple.screencapture type -string png

echo "Save screenshots to user screenshots directory instead of desktop."
run mkdir ~/Screenshots
run defaults write com.apple.screencapture location -string ~/Screenshots

echo "Disable menu transparency."
run defaults write com.apple.universalaccess reduceTransparency -int 1

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

# Disabled UX tweaks
#echo "Disable natural scrolling."
#run defaults write ~/Library/Preferences/.GlobalPreferences com.apple.swipescrolldirection -bool false
#
#echo "Disable press-and-hold for keys in favor of key repeat."
#run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
#
#echo "Use the dark theme."
#run defaults write ~/Library/Preferences/.GlobalPreferences AppleInterfaceStyle -string "Dark"
#
#echo "Turn off increased contrast. macOS 10.14 causes ugly white borders."
#run defaults write com.apple.universalaccess increaseContrast -int 0

# Security And Privacy Improvements
echo "Disable Safari from auto-filling sensitive data."
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillCreditCardData -bool false
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillFromAddressBook -bool false
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillMiscellaneousForms -bool false
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillPasswords -bool false

echo "Disable Safari from automatically opening files."
run defaults write ~/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads -bool false

#echo "Always block cookies and local storage in Safari."
#run defaults write ~/Library/Preferences/com.apple.Safari BlockStoragePolicy -bool false

echo "Enable Safari warnings when visiting fradulent websites."
run defaults write ~/Library/Preferences/com.apple.Safari WarnAboutFraudulentWebsites -bool true

#echo "Disable javascript in Safari."
#run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptEnabled -bool false
#run defaults write ~/Library/Preferences/com.apple.Safari WebKitJavaScriptEnabled -bool false

echo "Block popups in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false
run defaults write ~/Library/Preferences/com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false

#echo "Disable plugins and extensions in Safari."
#run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2WebGLEnabled -bool false
#run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false
#run defaults write ~/Library/Preferences/com.apple.Safari WebKitPluginsEnabled -bool false
#run defaults write ~/Library/Preferences/com.apple.Safari ExtensionsEnabled -bool false
#run defaults write ~/Library/Preferences/com.apple.Safari PlugInFirstVisitPolicy PlugInPolicyBlock
#run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
#run defaults write ~/Library/Preferences/com.apple.Safari WebKitJavaEnabled -bool false

echo "Safari should treat SHA-1 certificates as insecure."
run defaults write ~/Library/Preferences/com.apple.Safari TreatSHA1CertificatesAsInsecure -bool true

echo "Disable pre-loading websites with high search rankings."
run defaults write ~/Library/Preferences/com.apple.Safari PreloadTopHit -bool false

echo "Disable Safari search engine suggestions."
run defaults write ~/Library/Preferences/com.apple.Safari SuppressSearchSuggestions -bool true

echo "Enable Do-Not-Track HTTP header in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari SendDoNotTrackHTTPHeader -bool true

#echo "Disable pdf viewing in Safari."
#run defaults write ~/Library/Preferences/com.apple.Safari WebKitOmitPDFSupport -bool true

echo "Display full website addresses in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari ShowFullURLInSmartSearchField -bool true

#echo "Disable loading remote content in emails in Apple Mail."
#run defaults write ~/Library/Preferences/com.apple.mail-shared DisableURLLoading -bool true

#echo "Send junk mail to the junk mail box in Apple Mail."
#run defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail JunkMailBehavior -int 2

echo "Disable spotlight universal search (don't send info to Apple)."
run defaults write com.apple.safari UniversalSearchEnabled -int 0

echo "Disable Spotlight Suggestions, Bing Web Search, and other leaky data."
run python ./fix_leaky_data.py

echo "Disable Captive Portal Hijacking Attack."
run defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false

echo "Set screen to lock as soon as the screensaver starts."
run defaults write com.apple.screensaver askForPassword -int 1
run defaults write com.apple.screensaver askForPasswordDelay -int 5

echo "Don't default to saving documents to iCloud."
run defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "Disable crash reporter."
run defaults write com.apple.CrashReporter DialogType none

echo "Enable Stealth Mode. Computer will not respond to ICMP ping requests or connection attempts from a closed TCP/UDP port."
run defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true

echo "Set all network interfaces to use Cloudflare DNS (1.1.1.2 - malware blocking)."
run bash ./use_cloudflare_dns.sh

echo "Disable wake on network access."
run systemsetup -setwakeonnetworkaccess off

#echo "Disable Bonjour multicast advertisements."
#run defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES

# This is disabled by default, but sometimes people turn it on and forget to turn it back off again.
echo "Turn off remote desktop access."
run sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -configure -access -off

echo "Enable Mac App Store automatic updates."
run defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

#echo "Check for Mac App Store updates daily."
#run defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

#echo "Download Mac App Store updates in the background."
#run defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

echo "Install Mac App Store system data files & security updates."
run defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

#echo "Turn on Mac App Store auto-update."
#run defaults write com.apple.commerce AutoUpdate -bool true

# Blocklists

#echo "Block all Facebook domains."
#if ! grep --quiet facebook /etc/hosts; then
#    run cat block_facebook | sudo tee -a /etc/hosts
#else
#    echo "${dim}▹ Facebook domains already blocked. $reset"
#fi

# Install Applications

# Note: Before installing Homebrew, set the following settings in your .bash_profile for increased privacy.
# export HOMEBREW_NO_ANALYTICS=1
# export HOMEBREW_NO_INSECURE_REDIRECT=1
#echo "Install Homebrew."
#which -s brew
#if [[ $? != 0 ]] ; then
#    run '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
#else
#    run brew update
#fi

echo "Install brew taps."
run brew tap "homebrew/core"
run brew tap "homebrew/bundle"
run brew tap "homebrew/cask"
run brew tap "homebrew/cask-fonts"

echo "Installing a modern BASH and setting that as your shell."
run brew install bash
run sudo echo "/usr/local/bin/bash" >> /etc/shells
run chsh -s /usr/local/bin/bash

echo "Install and configure git."
run brew install git
run git config --global user.email "george.miranda@gmail.com"
git config --global user.name "gmiranda23"

echo "Install jq."
run brew install jq

echo "Install mas (Mac App Store Command Line)."
run brew install mas

echo "Install youtube-dl."
run brew install youtube-dl
run brew upgrade youtube-dl
run brew install ffmpeg
run brew upgrade ffmpeg

echo "Install fd (find alternative)."
run brew install "fd"

echo "Install fuzzy find CLI tool."
run brew install "fzf"

echo "Install ripgrep finder."
run brew install "ripgrep"

echo "Install thefuck CLI helper."
run brew install "thefuck"


# Install basic apps from brew cask
echo "Install Atom editor."
run brew cask "atom"

echo "Install Audacity."
#run brew cask "audacity"

echo "Install Caffeine."
run brew cask "caffeine"

echo "Install Choosy."
run brew cask "choosy"

echo "Install Dropbox."
run brew cask "dropbox"

echo "Install Firefox."
run brew cask "firefox"

echo "Install Chrome."
run brew cask "google-chrome"

echo "Install iTerm2."
run brew cask "iterm2"

echo "Install Krisp."
run brew cask "krisp"

echo "Install MacVim."
run brew cask "macvim"

echo "Install Menumeters."
run brew cask "menumeters"

echo "Install Moom."
run brew cask "moom"

echo "Install Paintbrush."
run brew cask "paintbrush"

echo "Install Screenflow."
run brew cask "screenflow"

echo "Install Skype."
run brew cask "skype"

echo "Install Spotify."
run brew cask "spotify"

echo "Install Timer."
run brew cask "timer"

#echo "Install VLC."
#run brew cask install vlc

echo "Install Zoom."
run brew cask "zoomus"

echo "Install terminal fonts."
run brew cask install "font-hack-nerd-font"
run brew cask install "font-inconsolata-for-powerline"


# Install all the Mac App Store applications using mas. https://github.com/mas-cli/mas
mac_app_login=$(mas account | grep @)
if [ -z "$mac_app_login" ] ; then
    chapter "Let's install Mac App Store applications. What is your Mac App Store email login? $bold"
    read mac_app_login
    run mas signin $mac_app_login
fi

echo "Install 1Password 7."
run mas install 1333542190

echo "Install Activity Timer."
run mas install 808647808

#echo "Install Keynote."
#run mas install 409183694

echo "Install Slack."
run mas install 803453959

echo "Install Speedtest."
run mas install 1153157709

echo "Install Things3."
run mas install 904280696

echo "Install Xcode."
run mas install 497799835

echo "Upgrade any Mac App Store applications."
run mas upgrade

echo "Run one final check to make sure software is up to date."
run softwareupdate -i -a

run killall Dock
run killall Finder
run killall SystemUIServer

chapter "Some settings will not take effect until you restart your computer."
headline " Your Mac is setup and ready!"
