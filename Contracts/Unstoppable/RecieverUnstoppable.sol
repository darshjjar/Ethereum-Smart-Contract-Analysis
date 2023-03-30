// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "solmate/src/auth/Owned.sol";
import { UnstoppableVault, ERC20 } from "../unstoppable/UnstoppableVault.sol";

contract ReceiverUnstoppable is Owned, IERC3156FlashBorrower {
    UnstoppableVault private immutable poolDetails;

    error UnexpectedFlashLoan();

    constructor(address poolAddress) Owned(msg.sender) {
        poolDetails = UnstoppableVault(poolAddress);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 borrowAmount,
        uint256 loanFee,
        bytes calldata
    ) external returns (bytes32) {
        if (initiator != address(this) || msg.sender != address(poolDetails) || token != address(poolDetails.asset()) || loanFee != 0)
            revert UnexpectedFlashLoan();

        ERC20(token).approve(address(poolDetails), borrowAmount);

        return keccak256("IERC3156FlashBorrower.onFlashLoan");
    }

    function executeFlashLoan(uint256 borrowAmount) external onlyOwner {
        address asset = address(poolDetails.asset());
        poolDetails.flashLoan(
            this,
            asset,
            borrowAmount,
            bytes("")
        );
    }
}