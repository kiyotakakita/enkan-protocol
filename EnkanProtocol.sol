// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title EnkanProtocol
 * @dev 模写・Forkを前提とし、古典（型）はコモンズ化、現役の先人には富を逆流させるプロトコル
 */
contract EnkanProtocol {
    string public name = "Enkan Resource Protocol";
    string public symbol = "ENKAN";

    uint256 public nextTokenId;
    
    // 次世代の若手を育てるための共有基金（コモンズ・プール）
    address payable public commonsPool;

    struct Lineage {
        uint256 parentTokenId; // 模写元の親（水源）NFTのID
        address payable creator;// 描いた本人（新人）
        uint96 backflowRate;   // 成功時に親へ逆流させる割合 (例: 1000 = 10%)
        bytes32 strokeProof;   // 模写した運筆ログのハッシュ（下積みの証明）
        bool isCommons;        // 著作権切れ・古典落語などの「型（コモンズ）」かどうか
    }

    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => Lineage) public lineages;

    event Traced(uint256 indexed newTokenId, uint256 indexed parentTokenId, address indexed creator);
    event BackflowPaid(uint256 indexed tokenId, address indexed recipient, uint256 amount);

    constructor() {
        // デプロイした人を初期のコモンズ・プール管理者に設定
        commonsPool = payable(msg.sender);
    }

    // 【1. 模写ミント (Fork & Trace)】
    // 新人は無料（ガス代のみ）で、先人の絵を模写した派生NFTをミントできる
    function forkAndTrace(
        uint256 parentTokenId,
        bytes32 strokeProof,
        uint96 backflowRate,
        bool isCommons
    ) external returns (uint256) {
        require(parentTokenId < nextTokenId || parentTokenId == 0, "Invalid parent");
        require(backflowRate <= 3000, "Max 30% backflow allowed");

        uint256 newTokenId = ++nextTokenId;
        ownerOf[newTokenId] = msg.sender;

        lineages[newTokenId] = Lineage({
            parentTokenId: parentTokenId,
            creator: payable(msg.sender),
            backflowRate: backflowRate,
            strokeProof: strokeProof,
            isCommons: isCommons
        });

        emit Traced(newTokenId, parentTokenId, msg.sender);
        return newTokenId;
    }

    // 【2. 川上への自動逆流 ＆ コモンズ循環】
    function supportOrPurchase(uint256 tokenId) external payable {
        require(msg.value > 0, "No funds sent");
        require(ownerOf[tokenId] != address(0), "Token does not exist");

        Lineage memory item = lineages[tokenId];

        // 親（水源）が存在する場合
        if (item.parentTokenId != 0) {
            Lineage memory parentItem = lineages[item.parentTokenId];
            address payable parentAuthor = parentItem.creator;

            // 親が「型（古典コモンズ）」の場合：10%は免除され、新人が100%受け取る
            if (parentItem.isCommons) {
                item.creator.transfer(msg.value);
                emit BackflowPaid(tokenId, item.creator, msg.value);
            } 
            // 親の作者がすでに不在（アドレス0等）の場合：未来の若手育成プールへ流して循環させる
            else if (parentAuthor == address(0)) {
                uint256 tributeToPool = (msg.value * item.backflowRate) / 10000;
                uint256 authorShare = msg.value - tributeToPool;

                commonsPool.transfer(tributeToPool);
                item.creator.transfer(authorShare);
                emit BackflowPaid(tokenId, commonsPool, tributeToPool);
            } 
            // 現役の先人がいる場合：正当な恩返しとして親の作者へ逆流させる
            else {
                uint256 tributeToParent = (msg.value * item.backflowRate) / 10000;
                uint256 authorShare = msg.value - tributeToParent;

                parentAuthor.transfer(tributeToParent);
                item.creator.transfer(authorShare);
                emit BackflowPaid(tokenId, parentAuthor, tributeToParent);
            }
        } else {
            // 親がいない元祖（水源）なら全額本人のもの
            item.creator.transfer(msg.value);
        }
    }
}
