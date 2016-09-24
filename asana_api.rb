require 'net/http'
require 'json'
require 'ostruct'
require_relative 'json_api_facade'
require_relative 'string_constants'

# Hides complexity of all required ASANA API CALLS
class AsanaAPI
  include StringConstants
  ASANA_BASE_URI = "https://app.asana.com/api/1.0"
  URI_ASANA_USERS_ME = URI("#{ASANA_BASE_URI}/users/me")
  URI_ASANA_USERS = URI("#{ASANA_BASE_URI}/users?opt_fields=name,email")
  URI_ASANA_WORKSPACES = URI("#{ASANA_BASE_URI}/workspaces")

  attr_reader :me

  def authorize_request(req)
    req.add_field('Authorization', "Bearer #{@pat}")
  end

  def authenticate(pat)
    @pat = pat
    puts ASANA_AUTHENTICATING
    uri = URI_ASANA_USERS_ME
    req = Net::HTTP::Get.new uri
    authorize_request req
    json_response = JSONAPIFacade::call(req, uri)
    if error?(json_response)
      return false
    else
      @me = OpenStruct.new json_response['data']
    end
  end

  def fetch_all_users
    @users = []
    puts ASANA_FETCHING_USERS
    uri = URI_ASANA_USERS
    req = Net::HTTP::Get.new uri
    authorize_request req
    json_response = JSONAPIFacade::call(req, uri)
    json_response['data'].each do |u|
      @users.push OpenStruct.new u
    end
    puts "Found #{@users.count} users."
  end

  def fetch_projects(ws)
    puts "Fetching Projects for #{ws.name}"
    uri = uri_asana_projects ws
    req = Net::HTTP::Get.new uri
    authorize_request req
    ws['projects'] = [] if ws['projects'].nil?
    json_response = JSONAPIFacade::call(req, uri)
    json_response['data'].each do |jp|
      p = OpenStruct.new jp
      ws['projects'].push p
    end
  end
  def fetch_tasks(ws, project)
    puts "Fetching Tasks for #{ws.name}/#{project.name}"
    uri = uri_asana_project_tasks project
    req = Net::HTTP::Get.new uri
    authorize_request req
    project['tasks'] = [] if project['tasks'].nil?
    json_response = JSONAPIFacade::call(req, uri)
    json_response['data'].each do |jt|
      t = OpenStruct.new jt
      t['assignee'] = OpenStruct.new t.assignee
      project['tasks'].push t
    end
  end

  def my_workspaces
    @my_workspaces
  end

  def print_my_workspaces
    @my_workspaces = []
    puts ASANA_LIST_OF_WORKSPACES
    puts "W (number) Workspace Name [workspace_id]"
    @me.workspaces.each_with_index do |jw, i|
      w = OpenStruct.new jw
      @my_workspaces.push w
      puts "W (#{(i+1)}) #{w.name} #{[w.id]}"
    end
  end

  def print_projects(ws_num)
    ws = @my_workspaces[ws_num]
    fetch_projects ws
    puts "P (number) Project Name [project_id]"
    ws.projects.each_with_index do |p, i|
      puts "P (#{(i+1)}) #{p.name} #{[p.id]}"
    end
  end

  def print_tasks(ws_num, p_num)
    ws = @my_workspaces[ws_num]
    p = ws.projects[p_num]
    fetch_tasks ws, p
    puts "#{p.tasks.count} tasks found."
    puts "T (number) Task Name @assignee [task_id]"
    p.tasks.each_with_index do |t, i|
      assignee = find_user_by_id(t.assignee.id)
      puts "T (#{(i+1)}) #{t.name} @[#{(assignee.name rescue nil)}] #{[t.id]}"
    end
  end

  def task_array(ws_num, p_num)
    ws = @my_workspaces[ws_num]
    p = ws.projects[p_num]
    a = []
    p.tasks.each do |t|
      a << {
        summary: t.name,
        description: t.notes
      }
    end
    a
  end

  private
    def error?(json_response)
      return !json_response['errors'].nil?
    end

    def get_error_message(json_response)
      return json_response['errors'][0]['message']
    end

    def uri_asana_projects(ws)
      URI "#{ASANA_BASE_URI}/workspaces/#{ws.id}/projects"
    end
    def uri_asana_project_tasks(p)
      URI "#{ASANA_BASE_URI}/projects/#{p.id}/tasks?opt_fields=notes,name,assignee"
    end
    def find_user_by_id(id)
      @users.each do |u|
        if u.id == id
          return u
        end
      end
      nil
    end
end