// SPDX-License-Identifier: MIT
pragma solidity >=0.7.1;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FakeVault is ERC20 {
    address public owner;
    IERC20 public acceptedToken;

    constructor(
        address _tokenAddress,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        owner = msg.sender;
        acceptedToken = IERC20(_tokenAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "FakeVault: You are not the owner.");
        _;
    }

    /** @dev User can use this function to deposits the acceptedToken, and receive
     * vault tokens in return.
     */
    function depositTokens(uint256 _amount) public {
        bool success = acceptedToken.transfer(address(this), _amount);
        require(success, "FakeVault: Deposit transfer failed.");
        IERC20(address(this))._mint(msg.sender, _amount);
    }

    /** @dev User can use this function to deposit the vault token and receive the exact
     * number of accepted tokens in return. (Normally this number would be calculated based)
     * on a % share of the pool.
     */
    function withdrawTokens(uint256 _amount) public {
        bool depositSuccess = IERC20(address(this)).transfer(address(this), _amount);
        require(depositSuccess, "FakeVault: Deposit transfer failed.");
        bool withdrawSuccess = acceptedToken._transfer(address(this), msg.sender, _amount);
        require(withdrawSuccess, "FakeVault: Withdraw transfer failed.");
    }
}
