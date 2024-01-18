// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { SplitFactoryV2 } from "../../src/splitters/SplitFactoryV2.sol";
import { SplitWalletV2 } from "../../src/splitters/SplitWalletV2.sol";

import { BaseTest } from "../Base.t.sol";

contract SplitFactoryV2Test is BaseTest {
    event SplitCreated(address indexed split, SplitFactoryV2.CreateSplitParams _split);

    function setUp() public override {
        super.setUp();
    }

    function testFuzz_create2Split(
        SplitReceiver[] memory _receivers,
        uint16 _distributionIncentive,
        address _owner,
        bytes32 _salt
    )
        public
    {
        SplitFactoryV2.CreateSplitParams memory params =
            getCreatSplitParams(_receivers, _distributionIncentive, _owner, address(this));

        address predictedAddress = splitFactory.predictDeterministicAddress(params, _salt);

        vm.expectEmit();
        emit SplitCreated(predictedAddress, params);
        SplitWalletV2 split = SplitWalletV2(splitFactory.createSplitDeterministic(params, _salt));

        assertEq(predictedAddress, address(split));
        assertEq(split.owner(), _owner);
    }

    function testFuzz_create2Split_Revert_SplitAlreadyExists(
        SplitReceiver[] memory _receivers,
        uint16 _distributionIncentive,
        address _owner,
        bytes32 _salt
    )
        public
    {
        testFuzz_create2Split(_receivers, _distributionIncentive, _owner, _salt);

        SplitFactoryV2.CreateSplitParams memory params =
            getCreatSplitParams(_receivers, _distributionIncentive, _owner, address(this));

        vm.expectRevert();
        splitFactory.createSplitDeterministic(params, _salt);
    }

    function testFuzz_createSplit(
        SplitReceiver[] memory _receivers,
        uint16 _distributionIncentive,
        address _owner
    )
        public
    {
        SplitFactoryV2.CreateSplitParams memory params =
            getCreatSplitParams(_receivers, _distributionIncentive, _owner, address(this));

        SplitWalletV2 split = SplitWalletV2(splitFactory.createSplit(params));

        assertEq(split.owner(), _owner);
    }

    function testFuzz_createSplit_sameParams(
        SplitReceiver[] memory _receivers,
        uint16 _distributionIncentive,
        address _owner
    )
        public
    {
        testFuzz_createSplit(_receivers, _distributionIncentive, _owner);

        SplitFactoryV2.CreateSplitParams memory params =
            getCreatSplitParams(_receivers, _distributionIncentive, _owner, address(this));

        SplitWalletV2 split = SplitWalletV2(splitFactory.createSplit(params));

        assertEq(split.owner(), _owner);
    }

    function testFuzz_isDeployed(
        SplitReceiver[] memory _receivers,
        uint16 _distributionIncentive,
        address _owner,
        bytes32 _salt
    )
        public
    {
        SplitFactoryV2.CreateSplitParams memory params =
            getCreatSplitParams(_receivers, _distributionIncentive, _owner, address(this));

        (address predictedAddress, bool isDeployed) = splitFactory.isDeployed(params, _salt);

        assertEq(isDeployed, false);

        testFuzz_create2Split(_receivers, _distributionIncentive, _owner, _salt);

        (predictedAddress, isDeployed) = splitFactory.isDeployed(params, _salt);

        assertEq(isDeployed, true);
    }
}
