// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title EnkanProtocol
 * @dev 模写・Forkを前提とし、成功時に水源（先人）へ富を逆流させる資源型NFTプロトコル
 */
contract EnkanProtocol {
    string public name = "Enkan Resource Protocol";
    string public symbol = "ENKAN";

    uint256 public nextTokenId;

    struct Lineage {
        uint256 parentTokenId; // 模写元の「親（水源）」NFTのID
        address payable creator;// 描いた本人（新人）
        uint96 backflowRate;   // 成功時に親へ逆流させる割合 (例: 1000 = 10%)
        bytes32 strokeProof;   // 模写した運筆ログ・タイムラプスのハッシュ（下積みの証明）
    }

    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => Lineage) public lineages;

    event Traced(uint256 indexed newTokenId, uint256 indexed parentTokenId, address indexed creator);
    event BackflowPaid(uint256 indexed tokenId, uint256 indexed parentTokenId, uint256 amountToParent, uint256 amountToAuthor);

    // 【1. 模写ミント (Fork & Trace)】
    // 新人は無料（ガス代のみ）で、先人の絵を模写した派生NFTをミントできる
    function forkAndTrace(
        uint256 parentTokenId,
        bytes32 strokeProof,
        uint96 backflowRate
    ) external returns (uint256) {
        require(parentTokenId < nextTokenId || parentTokenId == 0, "Invalid parent");
        require(backflowRate <= 3000, "Max 30% backflow allowed"); // 搾取防止の上限30%

        uint256 newTokenId = ++nextTokenId;
        ownerOf[newTokenId] = msg.sender;

        lineages[newTokenId] = Lineage({
            parentTokenId: parentTokenId,
            creator: payable(msg.sender),
            backflowRate: backflowRate,
            strokeProof: strokeProof
        });

        emit Traced(newTokenId, parentTokenId, msg.sender);
        return newTokenId;
    }

    // 【2. 川上への自動逆流 (Backflow Royalty)】
    // 作品が購入されたり、投げ銭が入った時に親へ自動逆流する
    function supportOrPurchase(uint256 tokenId) external payable {
        require(msg.value > 0, "No funds sent");
        require(ownerOf[tokenId] != address(0), "Token does not exist");

        Lineage memory item = lineages[tokenId];

        if (item.parentTokenId != 0) {
            address payable parentAuthor = lineages[item.parentTokenId].creator;
            uint256 tributeToParent = (msg.value * item.backflowRate) / 10000;
            uint256 authorShare = msg.value - tributeToParent;

            // 親へ逆流、残りは作者へ
            parentAuthor.transfer(tributeToParent);
            item.creator.transfer(authorShare);

            emit BackflowPaid(tokenId, item.parentTokenId, tributeToParent, authorShare);
        } else {
            // 親がいない元祖（水源）なら全額本人のもの
            item.creator.transfer(msg.value);
        }
    }
}
