// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenSwap is ERC20 {
    address public admin;
    uint256 public rate;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event TokensSold(address indexed seller, uint256 amount, uint256 earnings);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor(string memory name, string memory symbol, uint256 initialSupply, uint256 initialRate) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        admin = msg.sender;
        rate = initialRate;
    }

    function setRate(uint256 newRate) external onlyAdmin {
        rate = newRate;
    }

    function buyTokens(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");
        uint256 cost = amount * rate;
        require(msg.value >= cost, "Insufficient funds");

        _transfer(admin, msg.sender, amount);
        admin.transfer(cost);

        emit TokensPurchased(msg.sender, amount, cost);
    }

    function sellTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        uint256 earnings = amount * rate;

        _transfer(msg.sender, admin, amount);
        payable(msg.sender).transfer(earnings);

        emit TokensSold(msg.sender, amount, earnings);
    }
}
