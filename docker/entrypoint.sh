#!/usr/bin/expect

# Send `pocket stop` when interrupted to prevent corruption
proc graceful_exit {} {
    send_user "Gracefully exiting Pocket...\n"
    spawn sh -c "pocket stop"
}

trap graceful_exit {SIGINT SIGTERM}

# Command to run
set command $argv
set timeout -1

# Create work dir
spawn sh -c "mkdir -p /home/app/.pocket/config"
expect eof

# Pull variables from env if set
set genesis ""
catch {set genesis $env(POCKET_CORE_GENESIS)}

set chains ""
catch {set chains $env(POCKET_CORE_CHAINS)}

set config ""
catch {set config $env(POCKET_CORE_CONFIG)}

# Create dynamic config files
if {$genesis != ""} {
    set genesis_file [open /home/app/.pocket/config/genesis.json w]
    puts $genesis_file $genesis
    close $genesis_file
    send_user "GENESIS loaded from env\n"
}
if {$chains != ""} {
    set chains_file [open /home/app/.pocket/config/chains.json w]
    puts $chains_file $chains
    close $chains_file
    send_user "CHAINS loaded from env\n"
}
if {$config != ""} {
    set config_file [open /home/app/.pocket/config/config.json w]
    puts $config_file $config
    close $config_file
    send_user "CONFIG loaded from env\n"
}

set psswd ""
catch {set psswd $env(POCKET_PASSPHRASE)}
if {$psswd != ""} {
    log_user 0
    set command "pocket accounts create"
    spawn sh -c "$command"
    sleep 1
    send -- "$psswd\n"
    sleep 1
    send -- "$psswd\n"
    sleep 1
    log_user 1
}

set testnet ""
catch {set testnet $env(POCKET_TESTNET)}

set mainnet ""
catch {set mainnet $env(POCKET_MAINNET)}

set simulate ""
catch {set simulate $env(POCKET_SIMULATE)}

if {$testnet != ""} {
    send_user "Start  Testnet... \n"
    sleep 10
    spawn sh -c  "pocket start --seeds='d90094952a3a67a99243cca645cdd5bd55fe8d27@seed1.testnet.pokt.network:26668,2a5258dcdbaa5ca6fd882451f5a725587427a793@seed2.testnet.pokt.network:26669,a37baa84a53f2aab1243986c1cd4eff1591e50d0@seed3.testnet.pokt.network:26668,fb18401cf435bd24a2e8bf75ea7041afcf122acf@seed4.testnet.pokt.network:26669' --testnet"
}
if {$mainnet != ""} {
    send_user "Start  Mainnet... \n"
    sleep 10
    spawn sh -c  "pocket start --seeds='7c0d7ec36db6594c1ffaa99724e1f8300bbd52d0@seed1.mainnet.pokt.network:26662,cdcf936d70726dd724e0e6a8353d8e5ba5abdd20@seed2.mainnet.pokt.network:26663,74b4322a91c4a7f3e774648d0730c1e610494691@seed3.mainnet.pokt.network:26662,b3235089ff302c9615ba661e13e601d9d6265b15@seed4.mainnet.pokt.network:26663' --mainnet"
}

if {$simulate != ""} {
    send_user "Start  Simulate... \n"
    sleep 10
    spawn sh -c  "pocket start --simulateRelay"
}

expect eof
exit
