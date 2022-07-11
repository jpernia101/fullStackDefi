// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// what do we want ?
// 1-stakeTokens
// 2-unStakeTokens
// 3-issueTokens
// 4-addAllowedTokens
// 5-getEthValue

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TokenFarm is Ownable {
    address[] public allowedTokens;
    //mapping token address -> staker -> amount
    mapping(address => mapping(address => uint256)) public stakingBalance ;
    address[] public stakers; 
    mapping(address => uint256) public uniqueTokensStaked;
    IERC20 public dappToken;

    constructor(address _dappTokenAddress) public{
        dappToken = IERC20(_dappTokenAddress);
    }

    function stakeTokens(uint256 _amount, address _token) public {
        //What tokens can they stake ?
        //how much can they stake ?
        require(_amount > 0, "Amount must be greater than 0");
        require(tokenIsAllowed(_token) , "Token is currently not allowed");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        updateUniqueTokensStaked(msg.sender, _token);
        stakingBalance[_token][msg.sender] = stakingBalance[_token][msg.sender] + _amount;
        if(uniqueTokensStaked[msg.sender] == 1){
            stakers.push(msg.sender); 
        }

    }

    

    function updateUniqueTokensStaked(address _user, address _token) internal {
        if(stakingBalance[_token][_user] <=0){
            uniqueTokensStaked[_user] = uniqueTokensStaked[_user] + 1;
        }
    }

    

    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);   
    }

    function issueTokens() public onlyOwner {
        //issue tokens to al stakers  
        for(uint256 i = 0; i < stakers.length; i++){
            address recipient = stakers[i];
            uint256 userTotalValue = getUserTotalValue(recipient);
            //send them a tokens rewards based on their total value locked
            dappToken.transfer(recipient, userTotalValue);
        }
    }

    function getUserTotalValue(address _user) public view returns(uint256) {
        uint256 totalValue = 0;
        require(uniqueTokensStaked[_user] > 0 , "No Tokens Staked");
        for(uint i = 0 ; i < allowedTokens.length ; i++){
            totalValue = totalValue + getUserSingleTokenValue(_user, allowedTokens[i]);
        }
        return totalValue; 
    }

    function getUserSingleTokenValue(address _user, address _token) public view returns(uint256){
        // converting the token to USD 
        if(uniqueTokensStaked[_user] <= 0){
            return 0;
        }
        // price of token * stakingBalance[_token][user]
        (uint256 price, uint256 decimal ) = getTokenValue(_token);
        return (stakingBalance[_token][_user] * price / (10**decimal));
    }

    mapping(address => address) public tokenPriceFeedMapping;

    function setPriceFeedContract(address _token, address _priceFeed) public onlyOwner{
        tokenPriceFeedMapping[_token] = _priceFeed;
    }

    function getTokenValue(address _token) public view returns(uint256, uint256) {
        //price feed address 
        address priceFeedAddress = tokenPriceFeedMapping[_token];
        AggregatorV3Interface priceFeed =  AggregatorV3Interface(priceFeedAddress);
        (, int256 price , , ,) = priceFeed.latestRoundData();
        uint256 decimals = uint256(priceFeed.decimals());
        return (uint256(price), decimals);
    }

    function tokenIsAllowed(address _token) public returns (bool) {
        for(uint256 i=0; i < allowedTokens.length ; i++ ){
            if(allowedTokens[i] == _token){
                return true;
            }
            return false;
        }
    }

    function unstakeToken(address _token) public {
        uint256 balance = stakingBalance[_token][msg.sender];
        require(balance > 0, "Staking balance cannont be 0");
        IERC20(_token).transfer(msg.sender, balance);
        stakingBalance[_token][msg.sender] = 0;
        uniqueTokensStaked[msg.sender] = uniqueTokensStaked[msg.sender] - 1 ;
    }

    
}
