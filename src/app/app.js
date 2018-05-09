App = {
    web3Provider: null,
    contracts: {},

    ////////////////// init functions
    init: function() {
        return App.initWeb3();
    },

    initWeb3: function() {
        if (typeof web3 !== 'undefined') {
            App.web3Provider = web3.currentProvider;
            web3 = new Web3(web3.currentProvider);
        } else {
            App.web3Provider = new Web3(new Web3.providers.HttpProvider('http://localhost:7545'));
            web3 = new Web3(web3.web3Provider);
        }
        return App.initContract();
    },

    initContract: function() {
        $.getJSON('TeamMarket.json', function(data) {
            var TMArtifact = data;
            App.contracts.TeamMarket = TruffleContract(TMArtifact);

            App.contracts.TeamMarket.setProvider(App.web3Provider);

            App.initCompetitions();
            
            return App.markJoined();
        });
    },

    initCompetitions: async function() {
        var compsNum = await App.getCompetitions();
        
        window.compsNum = compsNum;

        $("#pagination").pagination(compsNum, {
            callback: App.pageCallBack,
            prev_text: '<<',
            next_text: '>>',
            ellipse_text: '...',
            current_page: 0,
            items_per_page: 10,
            num_display_entries: 4,
            num_edge_entries: 1
        });
    },

    markJoined: function() {
        return;
    },

    ////////////////// get from the blockchain
    getCompetitions: function() {
        return new Promise(function(resolve, reject) {
            App.contracts.TeamMarket.deployed().then(function(instance) {
                instance.getCompetitionLength.call().then(function(result) {
                    resolve(result);
                }).catch(function(err) {
                    alert("出现问题了……");
                    console.log(err.message);
                });
            });
        });
    },

    getCompInfo: function(id) {
        return new Promise(function(resolve, reject) {
            App.contracts.TeamMarket.deployed().then(function(instance) {
                instance.getCompInfo.call(id).then(function(result) {
                    resolve(result);
                }).catch(function(err) {
                    alert("出现问题了……");
                    console.log(err.message);
                });
            });
        });
    },

    ////////////////// post to the blockchain
    handleCreateUser: function() {
        
        var name = $("#name").val();
        var email = $("#email").val();
        var major = $("#major").val();

        var TMInstance;

        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }

            var account = accounts[0];

            App.contracts.TeamMarket.deployed().then(function(instance) {
                TMInstance = instance;

                return TMInstance.createUser(name, email, major);
            }).then(function () {
                // 不知道这里为什么不会运行
                // => 原来是因为刷新掉了，信息就被刷掉了
                alert("创建账号成功，等待写入区块链");
                window.location.href = "index.html";
            }).catch(function(err) {
                alert("有错误发生，创建账号失败");
                console.log(err.message);
            });
        });
    },

    handlePublish: function() {
        
        var theme = $("#theme").val();
        var intro = $("#intro").val();
        var requirement = $("#requirement").val();
        var status = $("#status").val();
        var max_num = $("#max_num").val();

        var TMInstance;

        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }

            var account = accounts[0];

            App.contracts.TeamMarket.deployed().then(function(instance) {
                TMInstance = instance;

                return TMInstance.publish(theme, intro, requirement, status, max_num);
            }).then(function (result) {
                console.log(result);
                alert("发布比赛成功，等待写入区块链");
                window.location.href = "index.html";
            }).catch(function(err) {
                alert("有错误发生，发布失败。");
                console.log(err.message);
            });
        });
    },

    handleJoin: function() {
        alert("加入成功！");
    },

    ////////////////// generate the fronted content
    pageCallBack: async function(index, container) {
        $("#comps").html('');
        var content = '';
        if (compsNum < 1) {
            content += App.injectTemplate('暂时还没有项目哦', '赶紧发布属于你自己的项目吧~', '', false);
            
            $("#comps").append(content);
            return;
        }
        var pageSize = 10;
        var start = index * pageSize;
        var end = Math.min((index + 1) * pageSize, compsNum);
        for (var i = start; i < end; i++) {
            var cInfo = await App.getCompInfo(i);
            // todo: 这里的点击事件还没完善
            content += App.injectTemplate(cInfo[1], cInfo[2], '', true);
        }
        $("#comps").append(content);
    },

    ////////////////// utils
    injectTemplate: function(title, para, action, hasData) {
        var content = '';
        var actionText;
        if (hasData) {
            content += '<div class="col s12 m6 l6">';
            actionText = '加入项目';
        } else {
            content += '<div class="col s12 container">';
            actionText = '创建项目';
        }
        return content 
        + '<div class="card hoverable small">'
        + '<div class="card-image">'
        + '<img src=\"' + 'img/gz.jpg' + '\">'
        + '<span class="card-title">' + title + '</span>'
        + '</div>'
        + '<div class="card-content">'
        + '<p>' + para + '</p>'
        + '</div>'
        + '<div class="card-action">'
        + '<a href="javascript:App.handleJoin(' + action + ')">' + actionText + '</a>'
        + '</div>'
        + '</div>'
        + '</div>';
    }
};

$(function() {
    $(window).on('load', function() {
        App.init();
    })
})