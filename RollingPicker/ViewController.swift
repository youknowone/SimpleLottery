//
//  ViewController.swift
//  RollingPicker
//
//  Created by USER on 2022/12/19.
//

import Speech
import UIKit

struct Person {
    var name: String
    var roman: String

    static func new(name: String, roman: String) -> Self {
        Person(name: name, roman: roman)
    }

    func lang() -> String {
        if !name.matches(of: /[가 - 힣]+/).isEmpty {
            return "ko-KR"
        } else {
            return "ja-JP"
        }
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var candidateTableView: UITableView!
    @IBOutlet var populatedTableView: UITableView!

    var candidates: [Person] = [
        ("name1", "nickname1"),
        ("name2", "nickname2"),
        ("name3", "nickname3"),
        ("name4", "nickname4"),
        ("name5", "nickname5"),
    ].map {
        pair in Person(name: pair.0, roman: pair.1)
    }

    var populated: [Person] = []

    @IBAction func shuffleTouched() {
        guard !candidates.isEmpty else {
            return
        }

        candidates.shuffle()

        for index in 0 ..< candidates.count * 2 {
            let i1 = Int(arc4random_uniform(UInt32(candidates.count)))
            let i2 = Int(arc4random_uniform(UInt32(candidates.count)))
            if i1 == i2 {
                continue
            }

            Timer.scheduledTimer(withTimeInterval: Double(index) * 0.08, repeats: false, block: { _ in
                self.candidateTableView.moveRow(at: IndexPath(row: i1, section: 0), to: IndexPath(row: i2, section: 0))
            })
        }

        Timer.scheduledTimer(withTimeInterval: Double(candidates.count) * 0.08 * 2 + 0.1, repeats: false, block: { _ in
            self.candidateTableView.reloadRows(at: (0 ..< self.candidates.count).map { i in IndexPath(row: i, section: 0) }, with: .automatic)
        })
    }

    func pick(at index: Int, animated: Bool) {
        let selected = candidates.remove(at: index)
        populated.append(selected)

        if animated {
            let selectedIndexPath = IndexPath(row: index, section: 0)
            candidateTableView.deleteRows(at: [selectedIndexPath], with: .left)
            populatedTableView.insertRows(at: [IndexPath(row: populated.count - 1, section: 0)], with: .right)
        } else {
            candidateTableView.reloadData()
            populatedTableView.reloadData()
        }

        // Create an utterance.
        let utterance = AVSpeechUtterance(string: selected.name)

        // Create a speech synthesizer.
        let synthesizer = AVSpeechSynthesizer()

        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }

    @IBAction func pickTouched() {
        guard !candidates.isEmpty else {
            return
        }

        let index = Int(arc4random_uniform(UInt32(candidates.count)))
        let selectedIndexPath = IndexPath(row: index, section: 0)
        candidateTableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .middle)

        pick(at: index, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func numberOfSections(in _: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        if tableView == candidateTableView {
            return candidates.count
        } else {
            return populated.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let person: Person
        if tableView == candidateTableView {
            let index = indexPath.row % candidates.count
            person = candidates[index]
        } else {
            person = populated[indexPath.row]
        }
        cell.textLabel!.text = person.name
        cell.detailTextLabel!.text = person.roman
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == candidateTableView {
            let index = indexPath.row % candidates.count
//            let removed = candidates.remove(at: index)
//            populated.append(removed)

            pick(at: index, animated: true)
        } else {
            let index = indexPath.row
            let removed = populated.remove(at: index)
            candidates.append(removed)

            candidateTableView.reloadData()
            populatedTableView.reloadData()
        }
    }
}
