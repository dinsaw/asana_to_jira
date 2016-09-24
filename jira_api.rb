require 'net/http'
require 'json'
require 'ostruct'
require_relative 'json_api_facade'
require_relative 'string_constants'

# Hides complexity of all required JIRA API CALLS
class JiraAPI
  include StringConstants

  attr_reader :myself
  attr_reader :projects
  attr_reader :issue_types

  def initialize(base_url_with_http)
    @jira_base_url = base_url_with_http + '/rest/api/2'
    @uri_jira_myself = URI "#{@jira_base_url}/myself"
    @uri_jira_projects = URI "#{@jira_base_url}/project"
    @uri_jira_issue_create_meta = URI "#{@jira_base_url}/issue/createmeta"
    @uri_jira_create_issues = URI "#{@jira_base_url}/issue/bulk"
  end

  def authorize_request(req)
    req.basic_auth(@username, @password)
  end

  def authenticate(username, password)
    @username = username
    @password = password
    puts JIRA_AUTHENTICATING
    uri = @uri_jira_myself
    req = Net::HTTP::Get.new uri
    authorize_request req
    json_response = JSONAPIFacade.call(req, uri)
    # if error?(json_response)
    #   return false
    # else
      @myself = OpenStruct.new json_response
    # end
  end

  def fetch_projects
    puts JIRA_FETCHING_PROJECTS
    uri = @uri_jira_projects
    req = Net::HTTP::Get.new uri
    authorize_request req
    json_response = JSONAPIFacade.call(req, uri)
    @projects = []
    json_response.each do |jp|
      p = OpenStruct.new jp
      @projects.push p
    end
  end

  def fetch_issue_create_meta(jira_p_num)
    project = @projects[jira_p_num]
    puts JIRA_FETCHING_ISSUE_CREATE_META
    uri = uri_issue_create_meta project
    req = Net::HTTP::Get.new uri
    authorize_request req
    json_response = JSONAPIFacade.call(req, uri)
    @issue_types = []
    json_response["projects"].each do |jp|
      meta = OpenStruct.new jp
      meta.issuetypes.each do |is|
        @issue_types.push OpenStruct.new is
      end
    end
    @issue_types.flatten!
  end

  def print_projects
    puts "P (number) Project Name [project_id]"
    @projects.each_with_index do |p, i|
      puts "P (#{(i+1)}) #{p.name} #{[p.id]}"
    end
  end

  def print_issue_types
    puts "I (number) Issue Name [issue_id]"
    @issue_types.each_with_index do |is, i|
      puts "I (#{(i+1)}) #{is.name} #{[is.id]}"
    end
  end

  def create_issues(issue_array, project_num, issue_type_num)
    updates = []
    project_id = @projects[project_num].id
    issue_type_id = @issue_types[issue_type_num].id
    issue_array.each do |h|
      updates << {
        update: {},
        fields: {
          project: {
            id: project_id
          },
          summary: h.fetch(:summary),
          issuetype: {
            id: issue_type_id
          },
          description: h.fetch(:description)
        }
      }
    end
    body = { issueUpdates: updates }.to_json
    uri = @uri_jira_create_issues
    req = Net::HTTP::Post.new uri
    req["content-type"] = 'application/json'
    req["cache-control"] = 'no-cache'
    req.body = body
    authorize_request req
    json_response = JSONAPIFacade.call(req, uri)
    puts json_response
  end

  def uri_issue_create_meta(project)
    URI "#{@jira_base_url}/issue/createmeta?projectIds=#{project.id}&projectKeys=#{project.key}"
  end

end