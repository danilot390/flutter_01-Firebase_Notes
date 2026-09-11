# CONTRIBUTING

Thank you for contributing to this project.

This project follows a structured development workflow designed to keep the codebase maintainable, undersatable, and reproductible.

## Development Workflow

All changes should follow this general workflow:

```Tree
Issue
  |
Implement branch
  |
Run quality checks
  |
Commit
  |
Push branch
  |
Open Pull request
  |
CI
  |
Review
  |
Merge
```

## Requirements

Before contributing, make sure you have:
- Flutter 
- FVM
- Git
- Access to the repository

Use the Flutter version configured by the project, check it with:
```cmd
fvm flutter --version
```

## Branches 

Do not develop directly on `main/master`.

Create a branch for each change.

### Branch naming
Use ine if the following prefixes:
```List
feature/
fix/
refactor/
test/
docs/
chore/
ci/
```

E.g.
```
feature/firebase-auth
```

Branch names should be short and describe the purpose of the work.

## Commits

Commits follow the Conventional Commits format.

E.g.

Feat: Add email authentication
Fix: Handle empty note title
Refactor: Simplify note validation

Keep commits focused, and avoid generic messages such as:

update 
changes
fix

A commit should represent one logical change whenever practical.

## Code Formating

Format Daetb code before opening a Pull Request
```cmd
fvm dart format .
```

To verify that formating is already correct
```cmd
fvm dart format --set-exit-if-changed .
```

## Static Analysis

Run:
``` cmd
fvm flutter analyze
```

New code should not include analyzer errors or warnings.

## Tests

Run the test suite:
```cmd
fvm flutter test 
```

When adding behavior, add appropiate tests.
Depending on the change, this may include:

- Unit tests
- Widget tests
- Integration tests

## Pull Requests

Pull Request should:

1. Explain what changed
2. Explain why the change was necessary
3. Describe how the change was tested 
4. Keep the scope focused
5. Pass all automated checks

Before opening a Pull Request, run:

```cmd
fvm flutter format --set-exit-if-changed
fvm flutter analyze
fvm flutter test
```

## Pull Request Checklist

Before requesting review:

- The code is formatted.
- Static analysis passsed.
- Test pass.
- New behavior has appropiate tests
- Documentation was updated when necessary
- No secrets or credentials were commited
- The Pull Request has a clear description
- The change is limited to the intended scope

## Security 

Never commit:

- Passwords
- API secrets
- Private keys
- Service-account credentials
- Authentication tokens
- Production secrets

If a secret is accidentally commited, consider it compromised and rotate inmediately.

## Issues 

Use GitHub Issues to track:

- Bugs
- Features
- Tasks
- Improvements
- Technical debt

Avoid using commit messages as a substitute for project tracking

## Code Review

Reviews should focus on:
- Correctness 
- Maintainability
- Security
- Tests
- Simplicity
- Consistency with project conventions.

The goal of review is to improve the codebase, not merely to find mistakes

