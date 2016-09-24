require 'base64'
require_relative 'asana_api'
require_relative 'jira_api'
require_relative 'string_constants'

class App
  include StringConstants
  @asana = nil
  @jira = nil
  def start
    @asana = AsanaAPI.new
    pat = nil
    puts ASANA_ENTER_PAT
    pat = gets
    asana_user = @asana.authenticate(pat)
    if !asana_user
      puts ASANA_AUTH_FAIL
      return
    end

    puts "You have logged in to Asana as #{@asana.me.name}(#{@asana.me.email})"
    @asana.fetch_all_users
    @asana.print_my_workspaces
    puts ASANA_ENTER_WS_NUM
    num = gets.to_i-1
    puts "You selected : #{@asana.my_workspaces[num].name}"
    @asana.print_projects num
    puts ASANA_ENTER_P_NUM
    p_num = gets.to_i - 1
    @asana.print_tasks num, p_num

    puts 'You have chosen to create all above tasks on JIRA.'
    puts 'Enter JIRA URL with http/https eg. https://team.atlassian.net'
    @jira = JiraAPI.new gets.chomp

    puts 'Enter your JIRA username:'
    jira_username = gets.chomp

    puts 'Enter your JIRA password:'
    jira_password = gets.chomp

    jira_user = @jira.authenticate(jira_username, jira_password)
    puts "You have logged in to Jira as #{@jira.myself.name}(#{@jira.myself.emailAddress})"

    @jira.fetch_projects
    @jira.print_projects

    puts JIRA_ENTER_P_NUM
    jira_p_num = gets.to_i - 1

    puts "Copy all tasks from
          ASANA[#{@asana.my_workspaces[num].name}
          [#{@asana.my_workspaces[num].projects[p_num].name}]]
          to JIRA [#{@jira.projects[jira_p_num].name}] ? (yes/no)"
    confirmed = gets.chomp == 'yes'

    if confirmed
      @jira.fetch_issue_create_meta(jira_p_num)
      @jira.print_issue_types
      puts 'Enter Issue Type Number'
      jira_i_num = gets.to_i - 1
      puts "You have selected #{@jira.issue_types[jira_i_num].name}"
      puts "Proceed to create issues on Jira?(yes/no)"
      confirmed = gets.chomp == 'yes'
      if confirmed
        tasks_to_create = @asana.task_array num, p_num
        @jira.create_issues(tasks_to_create, jira_p_num, jira_i_num)
      end
    end

  end
end

app = App.new
app.start