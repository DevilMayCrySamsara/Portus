require 'rails_helper'

describe NamespacePolicy do

  subject { described_class }

  let(:registry)    { create(:registry) }
  let(:admin)       { create(:user, admin: true) }
  let(:user)        { create(:user) }
  let(:owner)       { create(:user) }
  let(:viewer)      { create(:user) }
  let(:contributor) { create(:user) }
  let(:team) do
    create(:team,
           owners: [ owner ],
           contributors: [ contributor ],
           viewers: [ viewer ])
  end
  let(:namespace) { team.namespaces.first }

  permissions :pull? do

    it 'allows access to user with viewer role' do
      expect(subject).to permit(viewer, namespace)
    end

    it 'allows access to user with contributor role' do
      expect(subject).to permit(contributor, namespace)
    end

    it 'allows access to user with owner role' do
      expect(subject).to permit(owner, namespace)
    end

    it 'disallows access to user who is not part of the team' do
      expect(subject).to_not permit(user, namespace)
    end

    it 'allows access to any user if the namespace is public' do
      namespace.public = true
      expect(subject).to permit(user, namespace)
    end

    it 'allows access to admin users even if they are not part of the team' do
      expect(subject).to permit(admin, namespace)
    end

    it 'always allows access to a global namespace' do
      expect(subject).to permit(create(:user), registry.global_namespace)
    end

  end

  permissions :push? do

    it 'disallow access to user with viewer role' do
      expect(subject).to_not permit(viewer, namespace)
    end

    it 'allows access to user with contributor role' do
      expect(subject).to permit(contributor, namespace)
    end

    it 'allows access to user with owner role' do
      expect(subject).to permit(owner, namespace)
    end

    it 'disallows access to user who is not part of the team' do
      expect(subject).to_not permit(user, namespace)
    end

    context 'global namespace' do
      it 'allows access to administrators' do
        expect(subject).to permit(admin, registry.global_namespace)
      end

      it 'denies access to other users' do
        expect(subject).not_to permit(user, registry.global_namespace)
      end
    end

  end

end
