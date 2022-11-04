// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    mapping(address => uint256) public _indexOfHolders;
    address[] public _holders;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        _mint(msg.sender, 100 * 10**uint(decimals()));
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        require(_holders[recipient]);
        if (balanceOf[recipient] == 0) {
            uint256 maxIndex = _holders.length-1;
            uint256 holderIndex = _indexOfHolders[recipient];
            _holders[holderIndex] = _holders[maxIndex];
            _holders.pop();
            delete _indexOfHolders[recipient];
        }

        if (_indexOfHolders[msg.sender] == 0) {
            _holders.push(msg.sender);
            _indexOfHolders[msg.sender] = _holders.length-1;
        }

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }    
}
