// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// add to get balance, change 65, withdraw eth, emit amount 
contract PolygonPayements is Ownable {
    event val(uint, uint, address, uint256, int);
    AggregatorV3Interface internal priceFeed;
    uint256 public deviation = 5;
    uint256 public nft_price = 54; // usdc

    /**
     * Network: Rinkeby
     * Aggregator: ETH/USD
     * Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
     */

    //  Network: Rinkeby
    //  aggregator: usdc/eth_price
    //  address : 0xdCA36F27cbC4E38aE16C4E9f99D39b42337F6dcf

    // network : polygon mainnet
    // aggregator : MATIC/USD
    // Address : 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0 

    // network: mumbai 
    // aggregator: matic/usd
    // address : 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
    // decimals : 8

    constructor() {
        priceFeed = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);

    }

    function change_deviation(uint256 new_deviation) public onlyOwner{
        deviation = new_deviation;
    }

    function change_price(uint256 new_price) public onlyOwner{
        nft_price = new_price;
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();

        // int price = 148431541371;

        return price;
    }

    function getPriceForAmount(uint256 amount) public view returns (uint) { // check if return int or uint
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();

        // int price = 148431541371;

        return nft_price * amount * 10**26/uint(price); // 10**8 * 10**18
    }


    function pay_for_vishwas(uint256 amount) 
        payable 
        public{
        (
            /*uint80 roundID*/,
            int matic_price,             //changes to uint from int 
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();

        // int eth_price = 148431541371;

        uint price = nft_price * amount * 10**26/uint(matic_price); // se unsigned edge case w signed from chainlink // check for decimals from same contract?

        require(msg.value >= price - (price*deviation)/100 && msg.value <= price + (price*deviation)/100, "not the required matic");
        // payable(owner()).send(msg.value); // not recommended
        (bool success, ) = payable(owner()).call{value: msg.value}(""); // how to guard against reeentrancy
        if(!success){ 
            revert();
        }

        emit val (msg.value, uint(price), msg.sender, amount, matic_price); // address n all amount

        // send to totality

    }
    
    // function test(uint) view public returns(uint){
    //     // uint ans = uint(1)/148431541371;
    //     uint ans = 10/uint(3);
    //     return(ans);
    // }
        

}
