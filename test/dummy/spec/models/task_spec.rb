require 'spec_helper'

describe Task do
  
  #
  # has_moderated_association
  # has_many
  #
  
  context "has_many association:" do
    before do
      Object.send(:remove_const, 'Task')
      load 'task.rb'
      Object.send(:remove_const, 'Subtask')
      load 'subtask.rb'
      # TODO: set very obscure options
      Task.has_many :renamed_subtasks, :class_name => "Subtask"
      Task.has_moderated_association :renamed_subtasks
    end
    
    it "creates and associates subtask (create)" do
      task = Task.create! :title => "Task 1"
      Moderation.count.should eq(0)
      task.renamed_subtasks.create! :title => "Subtask 1"
    
      task = Task.first
      task.renamed_subtasks.count.should eq(0)
    
      Moderation.count.should eq(1)
      Moderation.last.accept
      Moderation.count.should eq(0)
      
      subtask = Task.first.renamed_subtasks.first
      subtask.title.should eq("Subtask 1")
    end
    
    it "creates and associates subtask (build, save task)" do
      task = Task.create! :title => "Task 1"
      Moderation.count.should eq(0)
      task.renamed_subtasks.build :title => "Subtask 1"
      task.save
    
      task = Task.first
      task.renamed_subtasks.count.should eq(0)
    
      Moderation.count.should eq(1)
      Moderation.last.accept
      Moderation.count.should eq(0)
      
      subtask = Task.first.renamed_subtasks.first
      subtask.title.should eq("Subtask 1")
    end
    
    it "creates and associates subtask (build, save subtask)", :broken => true do
      task = Task.create! :title => "Task 1"
      Moderation.count.should eq(0)
      subtask = task.renamed_subtasks.build :title => "Subtask 1"
      subtask.save
    
      task = Task.first
      task.renamed_subtasks.count.should eq(0)
    
      Moderation.count.should eq(1)
      Moderation.last.accept
      Moderation.count.should eq(0)
      
      subtask = Task.first.renamed_subtasks.first
      subtask.title.should eq("Subtask 1")
    end
    
    it "associates (<<) existing subtask" do
      task = Task.create! :title => "Task 1"
      Subtask.create! :title => "Subtask 1"
      Moderation.count.should eq(0)
      task.renamed_subtasks << Subtask.first

      task = Task.first
      task.renamed_subtasks.count.should eq(0)

      Moderation.count.should eq(1)
      Moderation.last.accept
      Moderation.count.should eq(0)

      subtask = Task.first.renamed_subtasks.first
      subtask.title.should eq("Subtask 1")
    end
    
    it "associates (push) existing subtask" do
      task = Task.create! :title => "Task 1"
      Subtask.create! :title => "Subtask 1"
      Moderation.count.should eq(0)
      task.renamed_subtasks.push Subtask.first

      task = Task.first
      task.renamed_subtasks.count.should eq(0)

      Moderation.count.should eq(1)
      Moderation.last.accept
      Moderation.count.should eq(0)

      subtask = Task.first.renamed_subtasks.first
      subtask.title.should eq("Subtask 1")
    end
    
    it "moderates deleting association" do
      task = Task.create! :title => "Task 1"
      task.renamed_subtasks.create! :title => "Subtask 1"
      Moderation.last.accept
      
      Task.last.renamed_subtasks.delete(Task.last.renamed_subtasks.last)
      Task.last.renamed_subtasks.count.should eq(1)
      
      Moderation.last.accept
      Task.last.renamed_subtasks.count.should eq(0)
    end
  end

  #
  # has_moderated_association
  # has_and_belongs_to_many
  #
  
  context "has_and_belongs_to_many association:" do
    before do
      Object.send(:remove_const, 'Task')
      load 'task.rb'
      Object.send(:remove_const, 'Subtask')
      load 'subtask.rb'
      # TODO: set very obscure options
      Task.has_and_belongs_to_many :renamed_subtasks, :class_name => "Subtask", :join_table => "tasks_jointable", :foreign_key => "m1_id", :association_foreign_key => "m2_id"
      Task.has_moderated_association :renamed_subtasks
    end
    
    it "creates and associates subtask (create)", :broken => true do
      task = Task.create! :title => "Task 1"
      Moderation.count.should eq(0)
      task.renamed_subtasks.create! :title => "Subtask 1"
    
      task = Task.first
      Subtask.count.should eq(0)
      task.renamed_subtasks.count.should eq(0)
    
      Moderation.count.should eq(1)
      Moderation.last.accept
      Moderation.count.should eq(0)
      
      subtask = Task.first.renamed_subtasks.first
      subtask.title.should eq("Subtask 1")
    end
  end

  #
  # has_moderated_association
  # has_many :through
  #
  
  context "has_many :through association:" do
    before do
      Object.send(:remove_const, 'Task')
      load 'task.rb'
      Object.send(:remove_const, 'Subtask')
      load 'subtask.rb'
      # TODO: set very obscure options
      Task.has_many :renamed_connections, :class_name => "TaskConnection", :foreign_key => "m1_id"
      Task.has_many :renamed_subtasks, :class_name => "Subtask", :through => :renamed_connections, :source => :renamed_subtask
      Subtask.has_many :renamed_connections, :class_name => "TaskConnection", :foreign_key => "m2_id"
      Subtask.has_many :renamed_tasks, :class_name => "Task", :through => :renamed_connections, :source => :renamed_task
      Task.has_moderated_association :renamed_subtasks
      Task.has_moderated_association :renamed_connections
    end
    
    it "associates subtask 1 (update)" do
      task = Task.create! :title => "Task 1"
      Moderation.count.should eq(0)
      
      conn = TaskConnection.new :title => "Connection 1"
      conn.renamed_subtask = Subtask.new :title => "Subtask 1"
      task.renamed_connections << conn
      task.save
      
      TaskConnection.count.should eq(0)
      Subtask.count.should eq(0)
    
      Moderation.last.accept
      Moderation.count.should eq(0)
      
      subtask = Task.first.renamed_subtasks.first
      subtask.title.should eq("Subtask 1")
    end
    
    it "associates subtask 2 (update)" do
      task = Task.create! :title => "Task 1"
      Moderation.count.should eq(0)
      
      task.renamed_subtasks.build :title => "Subtask 1"
      task.save
      
      TaskConnection.count.should eq(0)
      Subtask.count.should eq(0)
      Moderation.last.accept
      Moderation.count.should eq(0)
      Subtask.count.should eq(1)
      
      subtask = Task.first.renamed_subtasks.first
      subtask.title.should eq("Subtask 1")
    end
    
    it "associates subtask 3 (update)" do
      task = Task.create! :title => "Task 1"
      Moderation.count.should eq(0)
      
      task.renamed_subtasks.create! :title => "Subtask 1"
      
      TaskConnection.count.should eq(0)
      Subtask.count.should eq(0)
    
      Moderation.last.accept
      Moderation.count.should eq(0)
      Subtask.count.should eq(1)
      
      subtask = Task.first.renamed_subtasks.first
      subtask.title.should eq("Subtask 1")
    end
    
    it "associates subtask 1 (create)" do
      t = Task.new :title => "Task 1"
      t.renamed_subtasks.build :title => "Subtask 1"
      t.save
      
      Subtask.count.should eq(0)
      Task.first.renamed_subtasks.count.should eq(0)
      Task.count.should eq(1)
      
      Moderation.last.accept

      Task.first.renamed_subtasks.count.should eq(1)
      Task.first.renamed_subtasks.first.title.should eq("Subtask 1")
    end
  end
  
  #
  # has_moderated_association
  # has_one
  #
  
  context "has_one association:" do
    before do
      Object.send(:remove_const, 'Task')
      load 'task.rb'
      Object.send(:remove_const, 'Subtask')
      load 'subtask.rb'
      Task.has_one :renamed_subtask, :class_name => "Subtask"
      Task.has_moderated_association :renamed_subtask
    end
    
    it "creates and associates subtask (= new, task save)" do
      task = Task.create! :title => "Task 1"
      Moderation.count.should eq(0)
      task.renamed_subtask = Subtask.new :title => "Subtask 1"
      task.save
      debugger
    
      task = Task.first
      task.renamed_subtask.should be_nil
      Subtask.count.should eq(0)
    
      Moderation.count.should eq(1)
      Moderation.last.accept
      Moderation.count.should eq(0)
      
      subtask = Task.first.renamed_subtask
      subtask.title.should eq("Subtask 1")
    end
    
    it "creates and associates subtask (= create, task save)" do
      task = Task.create! :title => "Task 1"
      Moderation.count.should eq(0)
      task.renamed_subtask = Subtask.create! :title => "Subtask 1"
      task.save
    
      task = Task.first
      task.renamed_subtask.should be_nil
    
      Moderation.count.should eq(1)
      Moderation.last.accept
      Moderation.count.should eq(0)
      
      subtask = Task.first.renamed_subtask
      subtask.title.should eq("Subtask 1")
    end
    
    it "set subtask to nil (delete)" do
      task = Task.create! :title => "Task 1"
      task.renamed_subtask = Subtask.new :title => "Subtask 1"
      task.save
      Moderation.last.accept
      
      Moderation.count.should eq(0)
      Task.first.renamed_subtask.should_not be_nil
      
      Task.first.renamed_subtask = nil
      Task.first.renamed_subtask.should_not be_nil
      
      Moderation.last.accept
      Task.first.renamed_subtask.should be_nil
    end
  end
  
  #
  # has_moderated_create
  #
  
  context "create moderation with association:" do
    before do
      Object.send(:remove_const, 'Task')
      load 'task.rb'
      Object.send(:remove_const, 'Subtask')
      load 'subtask.rb'
      # TODO: set very obscure options
      Task.has_many :renamed_subtasks, :class_name => "Subtask"
      Task.has_moderated_create :with_associations => [:renamed_subtasks]
    end
    
    it "moderates create" do
      task = Task.create! :title => "Task 1"
      Moderation.count.should eq(1)
      Task.count.should eq(0)
      
      Moderation.last.accept
      Task.count.should eq(1)
      Task.first.title.should eq("Task 1")
    end
    
    it "moderates assoc on create" do
      task = Task.new :title => "Task 1"
      task.renamed_subtasks.build :title => "Subtask 1"
      task.save
      Subtask.count.should eq(0)
      Moderation.last.accept
      
      Task.last.renamed_subtasks.count.should eq(1)
      Task.last.renamed_subtasks.first.title.should eq("Subtask 1")
    end
  end
  
  #
  # has_moderated_destroy
  #
  
  context "destroy moderation:" do
    before do
      Object.send(:remove_const, 'Task')
      load 'task.rb'
      Object.send(:remove_const, 'Subtask')
      load 'subtask.rb'
      Task.has_moderated_destroy
    end
    
    it "moderates destroy" do
      Task.create! :title => "Task 1"
      Task.count.should eq(1)
      Task.first.destroy
      Task.count.should eq(1)
      Moderation.last.accept
      Task.count.should eq(0)
    end
  end
  
  #
  # has_moderated_attributes
  #
  
  context "moderates attributes:" do
    before do
      Object.send(:remove_const, 'Task')
      load 'task.rb'
      Object.send(:remove_const, 'Subtask')
      load 'subtask.rb'
      Task.has_moderated :title
    end
    
    it "moderates an attribute" do
      Task.create! :title => "Task 1"
      Task.first.title.should be_blank
      Moderation.last.accept
      Task.first.title.should eq("Task 1")
      Task.first.update_attribute(:title, "Task 2")
      Task.first.title.should eq("Task 1")
      Moderation.last.accept
      Task.first.title.should eq("Task 2")
    end
  end
  
  #
  # other features
  #
  
  context "common features:" do
    before do
      Object.send(:remove_const, 'Task')
      load 'task.rb'
      Object.send(:remove_const, 'Subtask')
      load 'subtask.rb'
      Task.has_moderated_create
      Task.class_eval do
        def get_moderation_attributes
          { :test => "ok" }
        end
      end
    end
    it "get_moderation_attributes can be overriden in model" do
      Task.create! :title => "Task 1"
      data = YAML::load(Moderation.last.data)[:create][:attributes]
      data.should_not be_blank
      data[:test].should_not be_blank
      data[:test].should eq("ok")
      data.keys.count.should eq(1)
    end
  end
  
  context "hooks:" do
    before do
      Object.send(:remove_const, 'Task')
      load 'task.rb'
      Object.send(:remove_const, 'Subtask')
      load 'subtask.rb'
      Task.has_moderated :title
      Task.moderation_creating do |moderation|
        moderation.data = "Test!"
      end
    end
    
    it "handles a creating hook properly" do
      Task.create! :title => "Task 1"
      Moderation.count.should eq(1)
      Moderation.last.data.should eq("Test!")
    end
  end
end
