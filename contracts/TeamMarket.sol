pragma solidity ^0.4.17;

contract TeamMarket {
    
    // 用户
    struct User {
        string name;  // 姓名
        string email;  
        string major;  // 专业
        uint[] joinedComps;  // 加入的比赛
        uint[] publishedComps;  // 发表的比赛
        bool isCreated;
    }

    struct Competition {
        address publisher;
        string theme;  // 主题
        string intro;  // 内容介绍
        string requirement;  // 对成员的要求
        string status;  // 运行状态：pending, processing, ended
        uint max_num;  // 最大人数
        uint cur_num;  // 当前人数
        uint cred_at;  // 创建时间
        address[] joinedUsers;  // 已加入的人
    }

    Competition[] comps;
    mapping(address => User) userPool;

    event createSuccess(address addr, string name, string email, string major);
    event joinSuccess(uint id, address addr);
    event publishSuccess(uint id, string theme, string intro, string requirement, 
    string status, uint max_num, uint cred_at);

    function getJoinedComps() public view returns (uint[]) {  // view 修饰的方法不能修改状态变量
        return userPool[msg.sender].joinedComps;
    }

    function getPublishedComps() public view returns (uint[]) {
        return userPool[msg.sender].publishedComps;
    }

    function getCompetitionLength() public view returns (uint) {
        return comps.length;
    }

    function getCompInfo(uint id) public view returns (
        address, string, string, string, string, uint, uint, uint
    ) {
        require(id < comps.length);
        Competition storage c = comps[id];

        return (c.publisher, c.theme, c.intro, c.requirement, 
            c.status, c.max_num, c.cur_num, c.cred_at);
    }

    function getUserInfo(address addr) public view returns (
        string, string, string
    ) {
        // assert(addr == msg.sender); 当合约调用合约时则不成立
        User storage u = userPool[addr];  // 不知道为什么这里的就是空值

        return (u.name, u.email, u.major);
    }

    function hasPublished(string theme, string intro) public view returns (bool) {
        User memory u = userPool[msg.sender];
        for (uint i = 0; i < u.publishedComps.length; i++) {
            Competition memory c = comps[i];
            // 不能直接比较字符串，这里通过比较哈希值来比较
            if (keccak256(c.theme) == keccak256(theme) 
                && keccak256(c.intro) == keccak256(intro))
                return true;
        }
        return false;
    }
    
    function hasJoined(uint id) public view returns (bool) {
        User storage u = userPool[msg.sender];  // 这里为什么用 storage 不用 memory？
        for (uint i = 0; i < u.joinedComps.length; i++) {
            if (u.joinedComps[i] == id)
                return true;
        }
        return false;
    }

    function createUser(string name, string email, string major) public {
        require(!userPool[msg.sender].isCreated);  // 不能重复创建
        
        uint[] memory joinedComps = new uint[](1);
        uint[] memory publishedComps = new uint[](1);
        User memory u = User(name, email, major, joinedComps, publishedComps, true);

        userPool[msg.sender] = u;

        emit createSuccess(msg.sender, name, email, major);
    }
    
    function publish(
        string theme, string intro, string requirement, 
        string status, uint max_num) public returns (uint) {

        require(userPool[msg.sender].isCreated);  // 创建了身份才能加入

        uint id = comps.length;  // 在数组中的位置，同样也是 publish id

        address[] memory u = new address[](max_num);
        Competition memory c = Competition(
            msg.sender, theme, intro, requirement, 
            status, max_num, 0, now, u);

        comps.push(c);
        userPool[msg.sender].publishedComps.push(id);

        emit publishSuccess(id, theme, intro, requirement, status, max_num, c.cred_at);

        return id;
    }

    function join(uint id) public returns (uint) {
        require(id < comps.length);
        require(userPool[msg.sender].isCreated);  // 创建了身份才能加入
        Competition storage c = comps[id];
        require(c.publisher != msg.sender && !hasJoined(id));  // 不能自己是发布者且不能已经加入

        c.joinedUsers.push(msg.sender);
        userPool[msg.sender].joinedComps.push(id);

        emit joinSuccess(id, msg.sender);

        return c.joinedUsers.length;
    }

    function () public {
        revert();
    }
}