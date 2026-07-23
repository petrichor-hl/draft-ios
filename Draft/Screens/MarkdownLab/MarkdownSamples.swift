//
//  MarkdownSamples.swift
//  Draft
//
//  Đoạn markdown dùng chung cho cả 3 màn hình (Text / AttributedString /
//  swift-markdown). Cố tình có đủ 4 loại để thấy rõ cách nào render được
//  cái gì: heading, inline (bold/italic/code/link), bullet list, table.
//

import Foundation

let markdownSamplesFull = """
# Vegetable Nutrition

Here are **quick takeaways** from the data. Values are per *100g*.

| Vegetable | Calories | Protein |
| --- | --- | --- |
| Mushroom | 22 | 3.1 |
| Spinach | 23 | 2.9 |
| Broccoli | 34 | 2.8 |

A few notes:

- **Highest protein**: mushroom, spinach
- **Lowest calories**: cucumber, tomato
- Most veggies are `low-calorie`

## Checklist:

- [x] My code follows the style guidelines of this project
- [x] I have performed a self-review of my own code
- [ ] I have added a feature flag where breaking change is introduced

Learn more at [Apple](https://apple.com).
"""
