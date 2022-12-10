// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract AirdropWF is Pausable, Ownable {

    using SafeMath for uint;
    event Received(address, uint);

    constructor() {}

    //Distribution of Matic According to no. of NFTs they hold
     function airDropAmountsNew(address payable[] memory _holders, uint[] memory _amnts) public onlyOwner {
        require(_holders.length == _amnts.length);
        uint n = _holders.length;


        for (uint i = 0; i < n; i++) {
            uint eachEth = _amnts[i];
            _holders[i].transfer(eachEth);
            
        }
    }

    // Distribute Matic equally to a set of addresses
    function airDrop(address payable[] memory _addrs) public onlyOwner {
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
    function withdraw() public onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }

}
