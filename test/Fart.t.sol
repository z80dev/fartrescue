// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MyERC20Token} from "../src/MYErc20.sol";

interface ITreasury {
    function queue(bytes32 proposalId) external returns (uint256 eta);
    /// @notice Executes a queued proposal
    /// @param targets The target addresses to call
    /// @param values The ETH values of each call
    /// @param calldatas The calldata of each call
    /// @param descriptionHash The hash of the description
    /// @param proposer The proposal creator
    function execute(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata calldatas,
        bytes32 descriptionHash,
        address proposer
    ) external payable;
    function delay() external view returns (uint256);
}

contract FartTest is Test {
    MyERC20Token public token;

    address tokenOwner = 0xdD94873Dd3d62233AB263D038091c84FcD247a4c;
    address safeOwner = 0xFB4A96541E1C70FC85Ee512420eB0B05C542df57;
    address safeAddress = 0xeB5977F7630035fe3b28f11F9Cb5be9F01A9557D;

    function setUp() public {
        token = MyERC20Token(0xA00dB4042b9537B8958289c7C68c5C74e341F766);
        console2.log("token address: ", address(token));
        console2.log("token owner: ", token.owner());
    }

    function testFailWithdrawToPurple() public {
        vm.prank(tokenOwner);
        token.withdrawToPurple();
    }

    function hashProposal(
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        bytes32 _descriptionHash,
        address _proposer
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_targets, _values, _calldatas, _descriptionHash, _proposer));
    }

    function buildProposal() public view returns (bytes32) {
        address[] memory targets = new address[](1);
        targets[0] = address(token);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("withdrawToPurple()");
        bytes32 descriptionHash = 0x0;
        address proposer = safeOwner;
        bytes32 proposalId = hashProposal(targets, values, calldatas, descriptionHash, proposer);
        return proposalId;
    }

    function testRescueFarts() public {
        // record balances before rescue
        uint256 preTokenBalance = address(token).balance;
        uint256 preTreasuryBalance = address(safeAddress).balance;

        // transfer token ownership
        vm.prank(tokenOwner);
        token.transferOwnership(safeAddress);
        assertEq(address(token.owner()), safeAddress);

        // queue proposal
        vm.startPrank(safeOwner);
        bytes32 proposalId = buildProposal();

        // fast forward to eta
        uint256 eta = ITreasury(safeAddress).queue(proposalId);
        vm.warp(eta);

        // craft and execute proposal
        address[] memory targets = new address[](1);
        targets[0] = address(token);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("withdrawToPurple()");
        bytes32 descriptionHash = 0x0;
        address proposer = safeOwner;
        ITreasury(safeAddress).execute(targets, values, calldatas, descriptionHash, proposer);

        // record balances after rescue
        uint256 postTokenBalance = address(token).balance;
        uint256 postTreasuryBalance = address(safeAddress).balance;

        // print balances
        console2.log("Token Contract ETH Balance Before Rescue", preTokenBalance);
        console2.log("Token Contract ETH Balance After Rescue", postTokenBalance);
        console2.log("Treasury ETH Balance Before Rescue", preTreasuryBalance);
        console2.log("Treasury ETH Balance After Rescue", postTreasuryBalance);
    }

}
