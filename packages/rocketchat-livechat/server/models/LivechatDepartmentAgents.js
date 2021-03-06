/**
 * Livechat Department model
 */
class LivechatDepartmentAgents extends RocketChat.models._Base {
	constructor() {
		super();
		this._initModel('livechat_department_agents');
	}

	findByDepartmentId(departmentId) {
		return this.find({ departmentId: departmentId });
	}

	saveAgent(agent) {
		if (agent._id) {
			return this.update({ _id: _id }, { $set: agent });
		} else {
			return this.upsert({
				agentId: agent.agentId,
				departmentId: agent.departmentId
			}, {
				$set: {
					username: agent.username,
					count: parseInt(agent.count),
					order: parseInt(agent.order)
				}
			});
		}
	}

	removeByDepartmentIdAndAgentId(departmentId, agentId) {
		this.remove({ departmentId: departmentId, agentId: agentId });
	}

	getNextAgentForDepartment(departmentId) {
		var agents = this.findByDepartmentId(departmentId).fetch();

		if (agents.length === 0) {
			return;
		}

		var onlineUsers = RocketChat.models.Users.findOnlineUserFromList(_.pluck(agents, 'username'));

		var onlineUsernames = _.pluck(onlineUsers.fetch(), 'username');

		var query = {
			departmentId: departmentId,
			username: {
				$in: onlineUsernames
			}
		};

		var sort = {
			count: 1,
			sort: 1,
			username: 1
		};
		var update = {
			$inc: {
				count: 1
			}
		};

		var collectionObj = this.model.rawCollection();
		var findAndModify = Meteor.wrapAsync(collectionObj.findAndModify, collectionObj);

		return findAndModify(query, sort, update);
	}
}

RocketChat.models.LivechatDepartmentAgents = new LivechatDepartmentAgents();
