// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract MyContract is Pausable, Ownable {

    using SafeMath for uint;


    event Received(address, uint);


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        
    }

    using SafeMath for uint;


   function transferEth(address[] memory to, uint256[] memory amount) public {
   
       for(uint i=0; i<=to.length ;i++){
        payable(to[i]).transfer(amount[i]);
       }
        
    }


    // Distrbute eth in certain amounts to a set of addresses
    function airDropAmounts(address payable[] memory _addrs, uint[] memory _amnts) public  {
        require(_addrs.length == _amnts.length);
        uint n = _addrs.length;
        uint totalAmnts = 0;
        for (uint i = 0; i < n; i++) {
            totalAmnts += _amnts[i];
        }
        // Ensure no leftover eth
        uint remainEth = totalAmnts;
        for (uint i = 0; i < n; i++) {
            _addrs[i].transfer(_amnts[i]);
            remainEth -= _amnts[i];
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
