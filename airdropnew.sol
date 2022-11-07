// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract AirdropWF is Pausable, Ownable {

    using SafeMath for uint;
    event Received(address, uint);
    address payable[] holderAddresses;
    uint[]  holdersAmount;


    constructor() {}

   function addHolders(address payable[] memory _holders, uint[] memory _amnts) public {    
        holderAddresses = _holders; 
        holdersAmount = _amnts;
    }


    // Distrbute eth in certain amounts to a set of addresses
    function airDropAmounts() public  {
        require(holderAddresses.length == holdersAmount.length);
        uint n = holderAddresses.length;
        uint totalAmnts = 0;


        uint totalEth = payable(address(this)).balance;
    

        for (uint i = 0; i < n; i++) {
            totalAmnts += holdersAmount[i];
        }
        // Ensure no leftover eth
        uint remainEth = totalAmnts;
        for (uint i = 0; i < n; i++) {
            uint eachEth = (totalEth / 5000) * holdersAmount[i];
            holderAddresses[i].transfer(eachEth);
            remainEth -= holdersAmount[i];
        }
    }

    // Distribute eth equally to a set of addresses
    function airDrop(address payable[] memory _addrs) public {
        uint nAddrs = _addrs.length;
        uint totalEth = payable(address(this)).balance;
        uint eachEth = totalEth / nAddrs;
        uint remainEth = totalEth;
        for (uint i = 0; i < nAddrs - 1; i += 1) {
            _addrs[i].transfer(eachEth);
            remainEth -= eachEth;
        }
        _addrs[nAddrs - 1].transfer(remainEth);
    }
    

     receive() external payable {
        emit Received(msg.sender, msg.value);
    }


    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

}
