pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TeamMarket.sol";

contract TestTeamMarket {
    TeamMarket tm = TeamMarket(DeployedAddresses.TeamMarket());

    function testCreateUser() public {
        string memory name = "路飞";
        string memory email = "luffy@onepiece.com";
        string memory major = "冒险";

        tm.createUser(name, email, major);

        // string memory _name;
        // string memory _email;
        // string memory _major;
        // (_name, _email, _major) = tm.getUserInfo(msg.sender);

        // Assert.equal("路飞", _name, "User not created successfully");
        // Assert.equal("luffy@onepiece.com", _email, "User not created successfully");
        // Assert.equal("冒险", _major, "User not created successfully");
    }

    function testPublish() public {
        string memory theme = "论文吹水大赛";
        string memory intro = "这是一个世界顶级的比赛";
        string memory requirement = "我们需要一个吹水界的大牛来和我们一起共创辉煌";
        string memory status = "pending";
        uint max_num = 5;

        uint id = tm.publish(theme, intro, requirement, status, max_num);

        string memory _theme;
        (, _theme, , , , , , ) = tm.getCompInfo(id);
        Assert.equal(theme, _theme, "Comp not created successfully");
    }
}
