class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    
    user ||= User.new # guest user (not logged in)
    
    if user.admin?
      can { true }
    elsif user.id
      # Repositories
      can [:create], Repository
      can [:write], Repository do |subject|
        subject.permission?(:editor, user)
      end
      can [:update, :destroy, :permissions], Repository do |subject|
        subject.permission?(:owner, user)
      end

      # Files
      manage  = [:new, :create]
      reading = [:files, :download, :entries_info, :diff, :history]
      can manage, Repository do |subject|#TODO
        subject.permission?(:editor, user)
      end

      # Ontology
      can :manage, Ontology do |subject|
        subject.permission?(:editor, user)
      end
      
      # Logics
      can [:update], Logic do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], Logic do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], Logic
      
      # LogicMappings
      can [:update], LogicMapping do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LogicMapping do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], LogicMapping
      
      # LanguageMappings
      can [:update], LanguageMapping do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LanguageMapping do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], LanguageMapping

      # LogicAdjoints
      can [:update], LogicAdjoint do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LogicAdjoint do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], LogicAdjoint

      # LanguageAdjoints
      can [:update], LanguageAdjoint do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LanguageAdjoint do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], LanguageAdjoint
      
      # Languages
      can [:update], Language do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], Language do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], Language

      # Serializations
      can [:create, :destroy, :update], Serialization
      
      # Team permissions
      can [:create, :read], Team
      can [:update, :destroy], Team do |subject|
        subject.admin?(user)
      end
      
      # Comments
      can [:create], Comment
      can [:destroy], Comment do |subject|
        subject.user == user || subject.commentable.permission?(:owner, user)
      end
      
      can [:create, :destroy], Metadatum do |subject|
        # TODO tests written?
        subject.user == user || subject.metadatable.permission?(:editor, user)
      end
      
    end
    
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
