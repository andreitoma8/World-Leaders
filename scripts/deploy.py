from brownie import WorldLeaders, accounts


def main():
    owner = accounts[0]
    nft = WorldLeaders.deploy({"from": owner})
