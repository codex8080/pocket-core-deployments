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
    spawn sh -c  "pocket start --seeds='3487f08b9e915f347eb4372b406326ffbf13d82c@testnet-seed-1.nodes.pokt.network:4301,27f4295d1407d9512a25d7f2ea91d1a415660c16@testnet-seed-2.nodes.pokt.network:4302,0beb1a93fe9ce2a3b058b98614f1ed0f5ad664d5@testnet-seed-3.nodes.pokt.network:4303,8fd656162dbbe0402f3cef111d3ad8d2723eef8e@testnet-seed-4.nodes.pokt.network:4304,80100476b67fea2e94c6b2f72e40cf8f6062ed21@testnet-seed-5.nodes.pokt.network:4305,370edf0882e094e83d4087d5f8801bbf24f5d931@testnet-seed-6.nodes.pokt.network:4306,57aff5a049846d14e2dcc06fdcc241d7ebe6a3eb@testnet-seed-7.nodes.pokt.network:4307,545fb484643cf2efbcf01ee2b7bc793ef275cd84@testnet-seed-8.nodes.pokt.network:4308' --testnet"
}
if {$mainnet != ""} {
    send_user "Start  Mainnet... \n"
    sleep 10
    spawn sh -c  "pocket start --seeds='03b74fa3c68356bb40d58ecc10129479b159a145@seed1.mainnet.pokt.network:20656,64c91701ea98440bc3674fdb9a99311461cdfd6f@seed2.mainnet.pokt.network:21656,0057ee693f3ce332c4ffcb499ede024c586ae37b@seed3.mainnet.pokt.network:22856,9fd99b89947c6af57cd0269ad01ecb99960177cd@seed4.mainnet.pokt.network:23856,f2a4d0ec9d50ea61db18452d191687c899c3ca42@seed5.mainnet.pokt.network:24856,f2a9705924e8d0e11fed60484da2c3d22f7daba8@seed6.mainnet.pokt.network:25856,582177fd65dd03806eeaa2e21c9049e653672c7e@seed7.mainnet.pokt.network:26856,2ea0b13ab823986cfb44292add51ce8677b899ad@seed8.mainnet.pokt.network:27856,a5f4a4cd88db9fd5def1574a0bffef3c6f354a76@seed9.mainnet.pokt.network:28856,d4039bd71d48def9f9f61f670c098b8956e52a08@seed10.mainnet.pokt.network:29856,5c133f07ed296bb9e21e3e42d5f26e0f7d2b2832@poktseed100.chainflow.io:26656,361b1936d3fbe516628ebd6a503920fc4fc0f6a7@seed.pokt.rivet.cloud:26656' --mainnet"
}

if {$simulate != ""} {
    send_user "Start  Simulate... \n"
    sleep 10
    spawn sh -c  "pocket start --simulateRelay"
}

expect eof
exit
