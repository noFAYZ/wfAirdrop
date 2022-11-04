// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable@4.7.3/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/proxy/utils/UUPSUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract MyContract is Initializable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {

    address[] addressArray;
    uint256[] amountArray;
    mapping(address => bool) public airdropped;
    mapping(address => uint256) public holders;

    using SafeMath for uint;

    event EtherTransfer(address beneficiary, uint amount);
    event LogTokenBulkSent(address token, uint256 total);



    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

     /*
  *  Holders list
  */
    function addHolders(address[] memory _holders, uint256[] memory _amount) public onlyOwner  {
        for (uint i = 0; i < _holders.length; i++) {
           addressArray[i] = _holders[i];
           amountArray[i] = _amount[i];
        }
    }

    function ethSendDifferentValue() public {

        uint sendAmount = amountArray[0];
        uint remainingValue = msg.value;

        require(remainingValue >= sendAmount);
     

        require(addressArray.length == amountArray.length);
        require(addressArray.length <= 255);

        for (uint8 i = 1; i < addressArray.length; i++) {
            remainingValue = remainingValue.sub(amountArray[i]);
            require(addressArray[i].send(amountArray[i]));
        }
        emit LogTokenBulkSent(0x000000000000000000000000000000000000bEEF, msg.value);

    }





    function dropEther(address[] memory _recipients, uint256[] memory _amount) public payable onlyOwner returns (bool) {
        uint total = 0;

        for(uint j = 0; j < _amount.length; j++) {
            total = total.add(_amount[j]);
        }

        require(total <= msg.value);
        require(addressArray.length == amountArray.length);


        for (uint i = 0; i < _recipients.length; i++) {
            require(addressArray[i] != address(0));

            payable(addressArray[i]).transfer(_amount[i]);

            emit EtherTransfer(addressArray[i], _amount[i]);
        }

        return true;
    }


    function withdrawEther(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }


    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}
