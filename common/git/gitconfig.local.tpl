# Git configuration for GPG signing
# Personal info and signing key from 1Password
# This file is NOT shared across machines

[user]
	name = op://Private/git-signing-config/name
	email = op://Private/git-signing-config/email
	signingkey = op://Private/git-signing-config/key_id

[gpg]
	program = gpg

[commit]
	gpgsign = true
