// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "forge-std/console.sol";
import {InvestmentVault} from "src/InvestmentVault.sol";

contract strategy is InvestmentVault{


    struct Strategy {
        uint256 AaveShares;
        uint256 CompoundShares;
        address owner;
    }

    mapping (uint16 => Strategy) public strategies;
    uint16 public strategiesID;

    constructor(address underlying, address _aavePool, address _aUsdc)
        InvestmentVault(underlying,_aavePool,_aUsdc)
    {

    }

    function AddStrategy(uint256 AaveShares, uint256 CompoundShares) public returns (uint16) {

        strategies[strategiesID++]=Strategy(AaveShares,CompoundShares,msg.sender);

        return strategiesID;
        
    }

    function ModifyStrategy(uint16 strategyID, uint256 AaveShares, uint256 CompoundShares) public{
        require(strategies[strategyID].owner==msg.sender,"You are not the owner of this strategy");
        strategies[strategyID]=Strategy(AaveShares,CompoundShares,msg.sender);
    }

    function InvestStrategy(uint16 strategyID, uint256 amount) public returns (uint256) {
        uint256 shares;
        return shares;
    }


}
