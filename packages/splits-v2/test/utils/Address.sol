// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.23;

import { IERC20 } from "@openzeppelin-v4.9.3/contracts/token/ERC20/IERC20.sol";

library Address {
    function balanceOf(address token, address account) internal view returns (uint256) {
        if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            return account.balance;
        } else {
            return IERC20(token).balanceOf(account);
        }
    }
}
