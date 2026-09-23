// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Clearly distinct tracker token. It is not Tether USDT.
contract TrackedToken {
    string public name = "USDT Price Tracker";
    string public symbol = "tUSDT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    address public owner;
    address public vault;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event VaultSet(address indexed vault);

    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }
    modifier onlyVault() { require(msg.sender == vault, "not vault"); _; }

    constructor(address initialOwner) {
        require(initialOwner != address(0), "zero owner");
        owner = initialOwner;
    }

    function setVault(address newVault) external onlyOwner {
        require(newVault != address(0), "zero vault");
        vault = newVault;
        emit VaultSet(newVault);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 a = allowance[from][msg.sender];
        require(a >= amount, "allowance");
        unchecked { allowance[from][msg.sender] = a - amount; }
        _transfer(from, to, amount);
        emit Approval(from, msg.sender, allowance[from][msg.sender]);
        return true;
    }

    function mint(address to, uint256 amount) external onlyVault {
        require(to != address(0), "zero recipient");
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function burn(address from, uint256 amount) external onlyVault {
        require(balanceOf[from] >= amount, "balance");
        unchecked {
            balanceOf[from] -= amount;
            totalSupply -= amount;
        }
        emit Transfer(from, address(0), amount);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero owner");
        owner = newOwner;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "zero recipient");
        require(balanceOf[from] >= amount, "balance");
        unchecked {
            balanceOf[from] -= amount;
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }
}
