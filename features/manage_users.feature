Feature: Manage Users

	As a user
	I want to login
	So that I can edit my profiles

	#@focus
	Background:
		Given the following user records:
		| email               | password   | password_confirmation | first_name | last_name | phone          | confirmed_at                      |
		| salemamba@gmail.com | secret1234 | secret1234            | salem      | amba      | (619) 123-1234 | "Sat, 14 Nov 2015 22:52:26 -0800" |

		Given the following jobseekerstatus values exist:
		| value                | description |
		| Unemployedlooking    | A jobseeker without any work and looking for a job|
		| Employedlooking      | A jobseeker with a job and looking for a job      |
		| Employednotlooking   | A jobseeker with a job and not looking for a job for now.|

	Scenario Outline: Updating User successfully
		Given I am on the home page
		And I am logged in as "<email>" with password "secret1234"
		And   I visit profile for "salem"
		Then  I should see "Edit User"

	    When  I fill in the fields:
			| Password              | newsecret1234 |
			| Password confirmation | newsecret1234 |
			| Current password      | secret1234    |
			| First name            | Jon           |
			| Last name             | Doe           |
			| Phone                 | 714-123-1234  |

		And   I press "Update"
		Then  I should see "Your account has been updated successfully."
		And   I should verify the change of first_name "Jon", last_name "Doe" and phone "714-123-1234"

		Examples:
			| email               |
			| salemamba@gmail.com |

	Scenario: One canceling login page
		Given I am on the Jobseeker Registration page
		And I press "Log In"
		Then I press "Cancel"
		And I should be on the Jobseeker Registration page

	Scenario: Two canceling login page
		Given I am on the home page
		And I press "Log In"
		Then I press "Cancel"
		And I should be on the home page
	# maybe fail after cancancan implementation

	Scenario: Redirecting back to previous page after successfull login
		Given I am on the Company Registration page
		And I am logged in as "<email>" with password "secret1234"
		And I should be on the Company Registration page

	Scenario: Confirmation of user email (and duplicate confirm)
		Given I am on the Jobseeker Registration page
		And I fill in the fields:
		| First Name            | Joseph          |
		| Last Name             | Smith           |
		| Email                 | jsmith@mail.com |
		| Phone                 | 111-222-3333    |
		| Password              | qwerty123       |
		| Password Confirmation | qwerty123       |
		| Year Of Birth         | 1980            |

		And I select "Unemployedlooking" in select list "Status"
		And I click the "Create Job seeker" button
		Then I should see "A message with a confirmation and link has been sent to your email address."
		And "jsmith@mail.com" should receive an email with subject "Confirmation instructions"
		When I open the email
		Then I should see "Confirm my account" in the email body
		And I follow "Confirm my account" in the email
		Then I should see "Your email address has been successfully confirmed."
		And I follow "Confirm my account" in the email
		Then I should see "Your email address has been successfully confirmed."
