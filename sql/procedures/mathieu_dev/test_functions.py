#!/usr/bin/env python3
"""
Test Runner for MentorLink User-Defined Functions
Simulates the SQL test execution with Python logic
"""

import json
from datetime import datetime

class TestResults:
    def __init__(self):
        self.tests = []
        self.passed = 0
        self.failed = 0

    def add_test(self, name, passed, details=""):
        self.tests.append({
            "name": name,
            "passed": passed,
            "details": details
        })
        if passed:
            self.passed += 1
        else:
            self.failed += 1

    def print_report(self):
        print("\n" + "="*80)
        print("USER-DEFINED FUNCTIONS TEST REPORT")
        print("="*80)
        print(f"\nTest Execution Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"\nTotal Tests: {len(self.tests)}")
        print(f"[PASS] Passed: {self.passed}")
        print(f"[FAIL] Failed: {self.failed}")
        print("\n" + "-"*80)
        print("DETAILED RESULTS:")
        print("-"*80 + "\n")

        for i, test in enumerate(self.tests, 1):
            status = "[PASS]" if test["passed"] else "[FAIL]"
            print(f"{i}. {status}: {test['name']}")
            if test["details"]:
                print(f"   Details: {test['details']}")
            print()


# Sample Data Structure (Simulated Database)
class MockDatabase:
    def __init__(self):
        self.sessions = {
            0: {'status': 'Scheduled', 'mentorship_id': 1010},
            1: {'status': 'Scheduled', 'mentorship_id': 1111},
            2: {'status': 'Completed', 'mentorship_id': 1212},
            3: {'status': 'Scheduled', 'mentorship_id': 1313},
            4: {'status': 'Completed', 'mentorship_id': 1414},
            5: {'status': 'Scheduled', 'mentorship_id': 1515},
            6: {'status': 'Completed', 'mentorship_id': 1616},
            7: {'status': 'Scheduled', 'mentorship_id': 1717},
            8: {'status': 'Scheduled', 'mentorship_id': 1818},
            9: {'status': 'Scheduled', 'mentorship_id': 1919},
            10: {'status': 'Completed', 'mentorship_id': 1818},
            11: {'status': 'Scheduled', 'mentorship_id': 1919},
        }

        self.mentorships = {
            1010: {'status': 'Active', 'subject_id': 222},
            1111: {'status': 'Active', 'subject_id': 111},
            1212: {'status': 'Ended', 'subject_id': 333},
            1313: {'status': 'Active', 'subject_id': 999},
            1414: {'status': 'Ended', 'subject_id': 444},
            1515: {'status': 'Active', 'subject_id': 101},
            1616: {'status': 'Active', 'subject_id': 555},
            1717: {'status': 'Ended', 'subject_id': 202},
            1818: {'status': 'Active', 'subject_id': 666},
            1919: {'status': 'Active', 'subject_id': 303},
        }

        self.goals = {
            201: {'mentorship_id': 1010, 'status': 'Achieved'},
            202: {'mentorship_id': 1010, 'status': 'Set'},
            203: {'mentorship_id': 1111, 'status': 'Achieved'},
            204: {'mentorship_id': 1111, 'status': 'Set'},
            205: {'mentorship_id': 1212, 'status': 'Achieved'},
            206: {'mentorship_id': 1212, 'status': 'Set'},
            207: {'mentorship_id': 1313, 'status': 'Achieved'},
            208: {'mentorship_id': 1313, 'status': 'Set'},
            209: {'mentorship_id': 1414, 'status': 'Achieved'},
            210: {'mentorship_id': 1515, 'status': 'Set'},
            211: {'mentorship_id': 1616, 'status': 'Achieved'},
            212: {'mentorship_id': 1717, 'status': 'Set'},
            213: {'mentorship_id': 1818, 'status': 'Set'},
            214: {'mentorship_id': 1919, 'status': 'Achieved'},
            215: {'mentorship_id': 1919, 'status': 'Set'},
        }

        self.subjects = {
            111: 'Python',
            222: 'Algebra',
            333: 'Creative Writing',
            444: 'Resume Building',
            555: 'Chemistry',
            666: 'Biology',
            777: 'Java',
            888: 'Calculus',
            999: 'Public Speaking',
            101: 'SQL',
            202: 'Finance',
            303: 'Psychology',
        }

        self.mentorship_members = {
            1010: {'mentor': 9, 'mentee': 3},
            1111: {'mentor': 1, 'mentee': 9},
            1212: {'mentor': 2, 'mentee': 8},
            1313: {'mentor': 8, 'mentee': 2},
            1414: {'mentor': 4, 'mentee': 10},
            1515: {'mentor': 10, 'mentee': 4},
            1616: {'mentor': 12, 'mentee': 5},
            1717: {'mentor': 5, 'mentee': 11},
            1818: {'mentor': 6, 'mentee': 12},
            1919: {'mentor': 11, 'mentee': 6},
        }

        self.users = {
            1: {'name': 'John Smith', 'email': 'johnsmith@gmail.com'},
            2: {'name': 'Lola Norrano', 'email': 'lolanorrano@gmail.com'},
            3: {'name': 'Jenny Terria', 'email': 'jennyterria@gmail.com'},
            4: {'name': 'Peter Lamm', 'email': 'peterlamm@gmail.com'},
            5: {'name': 'Flynn Lobster', 'email': 'flynnlobster@gmail.com'},
            6: {'name': 'Julius Cesar', 'email': 'juliuscesar@gmail.com'},
            7: {'name': 'Ghengis Khan', 'email': 'ghengiskhan@gmail.com'},
            8: {'name': 'Tina Turner', 'email': 'tinaturner@gmail.com'},
            9: {'name': 'Serge Ibaka', 'email': 'sergeibaka@gmail.com'},
            10: {'name': 'Susan Collins', 'email': 'susancollins@gmail.com'},
            11: {'name': 'Count Dracula', 'email': 'countdracula@gmail.com'},
            12: {'name': 'Naruto Uzumaki', 'email': 'narutouzumaki@gmail.com'},
        }

    def cancel_session(self, session_id):
        """Simulate CancelSession procedure"""
        if session_id is None:
            raise ValueError('Error: SessionID cannot be NULL')

        if session_id not in self.sessions:
            raise ValueError('Error: Session not found')

        session = self.sessions[session_id]
        if session['status'] == 'Cancelled':
            raise ValueError('Error: Session is already cancelled')

        if session['status'] == 'Completed':
            raise ValueError('Error: Cannot cancel a completed session')

        self.sessions[session_id]['status'] = 'Cancelled'
        return 'Session cancelled successfully'

    def end_mentorship(self, mentorship_id):
        """Simulate EndMentorship procedure"""
        if mentorship_id is None:
            raise ValueError('Error: MentorshipID cannot be NULL')

        if mentorship_id not in self.mentorships:
            raise ValueError('Error: Mentorship not found')

        mentorship = self.mentorships[mentorship_id]
        if mentorship['status'] == 'Ended':
            raise ValueError('Error: Mentorship is already ended')

        self.mentorships[mentorship_id]['status'] = 'Ended'
        return 'Mentorship ended successfully'

    def get_mentorship_summary(self, mentorship_id):
        """Simulate GetMentorshipSummary procedure"""
        if mentorship_id is None:
            raise ValueError('Error: MentorshipID cannot be NULL')

        if mentorship_id not in self.mentorships:
            raise ValueError('Error: Mentorship not found')

        mentorship = self.mentorships[mentorship_id]
        members = self.mentorship_members[mentorship_id]
        subject_id = mentorship['subject_id']

        # Count goals
        total_goals = 0
        achieved_goals = 0
        for goal in self.goals.values():
            if goal['mentorship_id'] == mentorship_id:
                total_goals += 1
                if goal['status'] == 'Achieved':
                    achieved_goals += 1

        # Count completed sessions
        completed_sessions = 0
        for session in self.sessions.values():
            if session['mentorship_id'] == mentorship_id and session['status'] == 'Completed':
                completed_sessions += 1

        mentor_id = members['mentor']
        mentee_id = members['mentee']

        return {
            'MentorshipID': mentorship_id,
            'SubjectID': subject_id,
            'SubjectName': self.subjects[subject_id],
            'MentorshipStatus': mentorship['status'],
            'MentorID': mentor_id,
            'MentorName': self.users[mentor_id]['name'],
            'MentorEmail': self.users[mentor_id]['email'],
            'MenteeID': mentee_id,
            'MenteeName': self.users[mentee_id]['name'],
            'MenteeEmail': self.users[mentee_id]['email'],
            'TotalGoals': total_goals,
            'AchievedGoals': achieved_goals,
            'CompletedSessions': completed_sessions,
        }

    def count_achieved_goals(self, mentorship_id):
        """Simulate CountAchievedGoals function"""
        if mentorship_id is None:
            return 0

        if mentorship_id not in self.mentorships:
            return 0

        count = 0
        for goal in self.goals.values():
            if goal['mentorship_id'] == mentorship_id and goal['status'] == 'Achieved':
                count += 1

        return count


# Run Tests
def main():
    db = MockDatabase()
    results = TestResults()

    # TEST 1: CancelSession - Valid Scheduled Session
    try:
        db.cancel_session(0)
        passed = db.sessions[0]['status'] == 'Cancelled'
        results.add_test(
            "CancelSession - Valid Scheduled Session",
            passed,
            f"Session 0 status changed to: {db.sessions[0]['status']}"
        )
    except Exception as e:
        results.add_test("CancelSession - Valid Scheduled Session", False, str(e))

    # TEST 2: CancelSession - Try to cancel already cancelled session
    try:
        db.cancel_session(0)
        results.add_test("CancelSession - Already Cancelled (should error)", False, "No error raised")
    except ValueError as e:
        passed = 'already cancelled' in str(e)
        results.add_test(
            "CancelSession - Already Cancelled (should error)",
            passed,
            f"Correctly raised: {str(e)}"
        )

    # TEST 3: CancelSession - Try to cancel completed session
    try:
        db.cancel_session(2)
        results.add_test("CancelSession - Completed Session (should error)", False, "No error raised")
    except ValueError as e:
        passed = 'completed' in str(e).lower()
        results.add_test(
            "CancelSession - Completed Session (should error)",
            passed,
            f"Correctly raised: {str(e)}"
        )

    # Reset session 0 for further tests
    db.sessions[0]['status'] = 'Scheduled'

    # TEST 4: EndMentorship - Valid Active Mentorship
    try:
        db.end_mentorship(1010)
        passed = db.mentorships[1010]['status'] == 'Ended'
        results.add_test(
            "EndMentorship - Valid Active Mentorship",
            passed,
            f"Mentorship 1010 status changed to: {db.mentorships[1010]['status']}"
        )
    except Exception as e:
        results.add_test("EndMentorship - Valid Active Mentorship", False, str(e))

    # TEST 5: EndMentorship - Try to end already ended mentorship
    try:
        db.end_mentorship(1212)
        results.add_test("EndMentorship - Already Ended (should error)", False, "No error raised")
    except ValueError as e:
        passed = 'already ended' in str(e)
        results.add_test(
            "EndMentorship - Already Ended (should error)",
            passed,
            f"Correctly raised: {str(e)}"
        )

    # TEST 6: GetMentorshipSummary - Active Mentorship (1111 - Python)
    try:
        summary = db.get_mentorship_summary(1111)
        passed = (
            summary['SubjectName'] == 'Python' and
            summary['MentorshipStatus'] == 'Active' and
            summary['AchievedGoals'] == 1 and
            summary['TotalGoals'] == 2
        )
        details = (
            f"Subject: {summary['SubjectName']}, Status: {summary['MentorshipStatus']}, "
            f"Goals: {summary['AchievedGoals']}/{summary['TotalGoals']} achieved"
        )
        results.add_test("GetMentorshipSummary - Active Mentorship (1111 - Python)", passed, details)
    except Exception as e:
        results.add_test("GetMentorshipSummary - Active Mentorship (1111 - Python)", False, str(e))

    # TEST 7: GetMentorshipSummary - Ended Mentorship (1212 - Creative Writing)
    try:
        summary = db.get_mentorship_summary(1212)
        passed = (
            summary['SubjectName'] == 'Creative Writing' and
            summary['MentorshipStatus'] == 'Ended' and
            summary['AchievedGoals'] == 1 and
            summary['TotalGoals'] == 2
        )
        details = (
            f"Subject: {summary['SubjectName']}, Status: {summary['MentorshipStatus']}, "
            f"Goals: {summary['AchievedGoals']}/{summary['TotalGoals']} achieved"
        )
        results.add_test("GetMentorshipSummary - Ended Mentorship (1212 - Creative Writing)", passed, details)
    except Exception as e:
        results.add_test("GetMentorshipSummary - Ended Mentorship (1212 - Creative Writing)", False, str(e))

    # TEST 8: GetMentorshipSummary - Active Mentorship (1313 - Public Speaking)
    try:
        summary = db.get_mentorship_summary(1313)
        passed = (
            summary['SubjectName'] == 'Public Speaking' and
            summary['MentorshipStatus'] == 'Active'
        )
        details = (
            f"Subject: {summary['SubjectName']}, Mentor: {summary['MentorName']}, "
            f"Mentee: {summary['MenteeName']}"
        )
        results.add_test("GetMentorshipSummary - Active Mentorship (1313 - Public Speaking)", passed, details)
    except Exception as e:
        results.add_test("GetMentorshipSummary - Active Mentorship (1313 - Public Speaking)", False, str(e))

    # TEST 9: CountAchievedGoals - Mentorship 1010 (Algebra)
    try:
        count = db.count_achieved_goals(1010)
        passed = count == 1
        results.add_test(
            "CountAchievedGoals - Mentorship 1010 (Algebra)",
            passed,
            f"Achieved goals count: {count} (expected 1)"
        )
    except Exception as e:
        results.add_test("CountAchievedGoals - Mentorship 1010 (Algebra)", False, str(e))

    # TEST 10: CountAchievedGoals - Mentorship 1111 (Python)
    try:
        count = db.count_achieved_goals(1111)
        passed = count == 1
        results.add_test(
            "CountAchievedGoals - Mentorship 1111 (Python)",
            passed,
            f"Achieved goals count: {count} (expected 1)"
        )
    except Exception as e:
        results.add_test("CountAchievedGoals - Mentorship 1111 (Python)", False, str(e))

    # TEST 11: CountAchievedGoals - Mentorship 1212 (Creative Writing - ENDED)
    try:
        count = db.count_achieved_goals(1212)
        passed = count == 1
        results.add_test(
            "CountAchievedGoals - Mentorship 1212 (Creative Writing - ENDED)",
            passed,
            f"Achieved goals count: {count} (expected 1)"
        )
    except Exception as e:
        results.add_test("CountAchievedGoals - Mentorship 1212 (Creative Writing - ENDED)", False, str(e))

    # TEST 12: CountAchievedGoals - All Mentorships Summary
    try:
        summary_data = {}
        for mid in db.mentorships.keys():
            count = db.count_achieved_goals(mid)
            subject = db.subjects[db.mentorships[mid]['subject_id']]
            summary_data[mid] = {
                'subject': subject,
                'achieved': count
            }

        # Verify counts are correct
        expected = {
            1010: 1,  # Algebra: 1 achieved
            1111: 1,  # Python: 1 achieved
            1212: 1,  # Creative Writing: 1 achieved
            1313: 1,  # Public Speaking: 1 achieved
            1414: 1,  # Resume Building: 1 achieved
            1515: 0,  # SQL: 0 achieved
            1616: 1,  # Chemistry: 1 achieved
            1717: 0,  # Finance: 0 achieved
            1818: 0,  # Biology: 0 achieved
            1919: 1,  # Psychology: 1 achieved
        }

        all_correct = all(
            db.count_achieved_goals(mid) == expected[mid]
            for mid in expected
        )

        results.add_test(
            "CountAchievedGoals - All Mentorships Summary",
            all_correct,
            f"Verified counts for all 10 mentorships"
        )
    except Exception as e:
        results.add_test("CountAchievedGoals - All Mentorships Summary", False, str(e))

    # TEST 13: Session Status Distribution
    try:
        status_counts = {}
        for session in db.sessions.values():
            status = session['status']
            status_counts[status] = status_counts.get(status, 0) + 1

        passed = (
            status_counts.get('Scheduled', 0) == 8 and
            status_counts.get('Completed', 0) == 4 and
            status_counts.get('Cancelled', 0) == 0  # One was cancelled in TEST 1
        )
        details = f"Status distribution: {status_counts}"
        results.add_test(
            "Session Status Distribution",
            passed,
            details
        )
    except Exception as e:
        results.add_test("Session Status Distribution", False, str(e))

    # Print results
    results.print_report()

    # Return summary
    print("\n" + "="*80)
    print("SUMMARY:")
    print("="*80)
    print(f"[PASS] {results.passed} tests passed")
    print(f"[FAIL] {results.failed} tests failed")
    print(f"[INFO] Success Rate: {(results.passed/len(results.tests)*100):.1f}%")
    print("="*80 + "\n")

    return results.failed == 0


if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
