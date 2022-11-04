// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Solidity by Example";
    string public symbol = "SOLBYEX";
    uint8 public decimals = 18;
    uint public lastInterestDate = block.timestamp - 1 days;

    mapping(address => uint256) public _indexOfHolders;
    address[] public _holders;    

    event PutInterest(address, uint256, uint256);

    struct capTable {
        address addr;
        uint256 value;
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        if (balanceOf[msg.sender] == 0) {
            uint256 maxIndex = _holders.length;
            uint256 holderIndex = _indexOfHolders[msg.sender];
            address addr = _holders[maxIndex-1];

            _indexOfHolders[addr] = holderIndex;
            _holders[holderIndex-1] = _holders[maxIndex-1];
            _holders.pop();
            delete _indexOfHolders[msg.sender];
        }

        if (_indexOfHolders[recipient] == 0) {
            _holders.push(recipient);
            _indexOfHolders[recipient] = _holders.length;
        }

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }    

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;

        if (_indexOfHolders[msg.sender] == 0) {
            _holders.push(msg.sender);
            _indexOfHolders[msg.sender] = _holders.length;
        }

        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        if (balanceOf[msg.sender] == 0) {
            uint256 maxIndex = _holders.length;
            uint256 holderIndex = _indexOfHolders[msg.sender];
            address addr = _holders[maxIndex-1];

            _indexOfHolders[addr] = holderIndex;
            _holders[holderIndex-1] = _holders[maxIndex-1];
            _holders.pop();
            delete _indexOfHolders[msg.sender];
        }

        emit Transfer(msg.sender, address(0), amount);
    }

    function getDuration() external view returns (uint) {
        uint duration = block.timestamp - lastInterestDate;
        duration = duration.div(60).div(60).div(24);
        return duration;
    }

    function getCapTable() external view returns (address[] memory, uint256[] memory) {
        uint256[] memory values = new uint256[](_holders.length);

        for (uint ii = 0; ii < _holders.length; ii++) {
            values[ii] = balanceOf[_holders[ii]];
        }

        return (_holders, values);
    }
}
