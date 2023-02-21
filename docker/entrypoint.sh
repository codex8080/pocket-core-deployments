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

# If key isn't passed in, start the node
if { $env(POCKET_CORE_KEY) eq "" }  {
    log_user 0
    set command "pocket accounts create"
    send_user "Create  INFO  Command:$command\n"
    spawn sh -c "$command"
    sleep 1
    send -- "$env(POCKET_CORE_PASSPHRASE)\n"
    sleep 1
    send -- "$env(POCKET_CORE_PASSPHRASE)\n"
    sleep 1
    log_user 1
} else {
# If key is passed in, load it into the local accounts
    log_user 0
    spawn sh -c "echo 'Debug Info Command Import-raw'"
    spawn pocket accounts import-raw $env(POCKET_CORE_KEY)
    sleep 1
    send -- "$env(POCKET_CORE_PASSPHRASE)\n"
    expect eof
    spawn sh -c "pocket accounts set-validator `pocket accounts list | cut -d' ' -f2- `"
    sleep 1
    send -- "$env(POCKET_CORE_PASSPHRASE)\n"
    expect eof
    log_user 1
    spawn sh -c "$command"
}

if { $env(POCKET_TESTNET) eq "true" }  {
    send_user "Start  Testnet... \n"
    sleep 60
    spawn sh -c  "pocket start --seeds='3487f08b9e915f347eb4372b406326ffbf13d82c@testnet-seed-1.nodes.pokt.network:4301,27f4295d1407d9512a25d7f2ea91d1a415660c16@testnet-seed-2.nodes.pokt.network:4302,0beb1a93fe9ce2a3b058b98614f1ed0f5ad664d5@testnet-seed-3.nodes.pokt.network:4303,8fd656162dbbe0402f3cef111d3ad8d2723eef8e@testnet-seed-4.nodes.pokt.network:4304,80100476b67fea2e94c6b2f72e40cf8f6062ed21@testnet-seed-5.nodes.pokt.network:4305,370edf0882e094e83d4087d5f8801bbf24f5d931@testnet-seed-6.nodes.pokt.network:4306,57aff5a049846d14e2dcc06fdcc241d7ebe6a3eb@testnet-seed-7.nodes.pokt.network:4307,545fb484643cf2efbcf01ee2b7bc793ef275cd84@testnet-seed-8.nodes.pokt.network:4308' --testnet"
}

}
expect eof
exit
