from black import token
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account, get_contract , INITIAL_VALUE
import pytest
from brownie import network , exceptions
from scripts.deploy import deploy_token_farm_and_dapp_token


def test_set_price_feed_contract():
    #arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    account = get_account()
    non_owner = get_account(index=1)
    token_farm , dapp_token = deploy_token_farm_and_dapp_token()
    #act 
    price_feed_address = get_contract("eth_usd_price_feed")
    token_farm.setPriceFeedContract(dapp_token.address, price_feed_address, {"from": account})
    #assert
    assert token_farm.tokenPriceFeedMapping(dapp_token.address) == price_feed_address
    with pytest.raises(exceptions.VirtualMachineError):
        token_farm.setPriceFeedContract(dapp_token.address, price_feed_address, {"from": non_owner})

def test_staking_tokens(amount_staked):
    # Arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing!")
    account = get_account()
    token_farm, dapp_token = deploy_token_farm_and_dapp_token()
    # Act
    dapp_token.approve(token_farm.address, amount_staked, {"from": account})
    token_farm.stakeTokens(amount_staked, dapp_token.address, {"from": account})
    #Assert
    assert(
        token_farm.stakingBalance(dapp_token.address, account.address) == amount_staked
    )
    assert token_farm.stakers(0) == account.address
    assert token_farm.uniqueTokensStaked(account.address) == 1

    return token_farm, dapp_token


def test_issue_tokens(amount_staked):
    # Arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing!")
    account = get_account()
    token_farm , dapp_token = test_staking_tokens(amount_staked)
    starting_balance = dapp_token.balanceOf(account.address)
    #act
    token_farm.issueTokens({"from": account})
    #we are staking 1 dapp_token == in price to 1 ETH 
    #soo....we should get 2,000 dapp tokens in reward 
    #since the price of ETH is $2,000 usd (helpful_scripts.deploy_mocks)
    assert(
        dapp_token.balanceOf(account.address) == starting_balance + INITIAL_VALUE
    )
