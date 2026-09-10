# Rubric Pipeline starter pack

This folder is the shared corpus for the CS357 Rubric Pipeline Lab. Both paths through the lab (the Python pipeline and the promptfoo configuration) start from the same rubric and the same twelve submissions, so every pair's judge is measured against the same material.

## What each file is

| File | What it is | Which path uses it |
|------|------------|--------------------|
| `rubric.json` | A rubric for a persuasive paragraph: four criteria (thesis clarity, evidence, organization, mechanics), each with four levels named preemerging, beginning, progressing, and proficient, and integer weights that sum to 100 | Code path reads it directly; no-code path copies each criterion's descriptors into an `llm-rubric` assertion |
| `submissions/s01.txt` through `submissions/s12.txt` | Twelve short paragraphs on everyday topics, one per file | Code path (the pipeline walks this folder) |
| `dataset.csv` | The same twelve paragraphs as a two-column CSV with header `id,answer`; answers are quoted and embedded quotes are doubled; the empty submission is an empty field | No-code path (promptfoo reads it as `tests: file://dataset.csv`) |
| `README.md` | This file | Both |

The rubric's `levels` field is a list of objects, each with a numeric `level` (4 down to 1), a `name`, and a one-sentence `descriptor`. The lab's judge prompt prints the number and the name together so the model sees "Level 4 (proficient)".

## Planted edge cases

Three of the twelve are there to test the pipeline rather than the writer.

- `s10` is empty (zero bytes). A pipeline that fails closed flags it (the lab's code marks it `EMPTY_FILE`) instead of sending a blank prompt to the model and recording whatever comes back.
- `s11` is off topic: a pancake recipe, not a persuasive paragraph. The rubric asks the judge to award level 1 across the board for off-topic content. A judge that gives the recipe credit for "organization" or "mechanics" is grading prose quality instead of the artifact the rubric describes.
- `s12` is verbose but weak: over 200 words on campus recycling that never state a claim or offer a specific piece of support. It is the length-bias probe. A judge that scores it above the short weak paragraphs (`s07` through `s09`) is rewarding word count.

## Intended quality tier per id

Record your own blind scores for every criterion before you read this table, and before you run the judge. Once you have seen the table or the judge's output, your scores are anchored and the agreement numbers in Part 2 of the lab stop meaning anything.

| id | Topic | Intended tier | What to look for |
|----|-------|---------------|------------------|
| s01 | Campus dining hours | Strong | Claim in sentence one, two specific supports, a rebutted objection, a closing sentence, clean mechanics |
| s02 | Four-day school week | Strong | Same shape as s01; contains a quoted objection, so it exercises CSV quote doubling in `dataset.csv` |
| s03 | Protected bike lanes | Strong | Two numeric supports and a rebutted objection |
| s04 | Library hours during finals | Adequate | Clear claim, one personal example as the only support, a missing hyphen and a missing comma |
| s05 | Dining hall composting | Adequate | Clear claim, one specific support, a flat closing sentence |
| s06 | Shuttle to the train station | Adequate | Clear claim, support that stays general ("other colleges do this"), one comma splice |
| s07 | Phones in class | Weak | Topic named but no position taken, no support, "Its" for "It's" |
| s08 | School uniforms | Weak | Position taken but supported only by "nobody likes them," five or more spelling and punctuation errors, missing final period |
| s09 | Campus parking | Weak | Topic named but no arguable claim, one long run-on sentence, no closing |
| s10 | (none) | Edge case: empty | Zero bytes; the pipeline should flag it, not grade it |
| s11 | Pancake recipe | Edge case: off topic | Well written, but not a persuasive paragraph; level 1 on every criterion is the intended result |
| s12 | Campus recycling | Edge case: verbose but weak | 218 words, clean mechanics, no claim and no specific support; it should land near s07 through s09 on the weighted total |

"Strong" means you would expect mostly level 4 (proficient) marks. "Adequate" means a mix of level 3 and level 2. "Weak" means mostly level 2 and level 1. Reasonable graders will disagree on individual cells, especially in the adequate tier; that disagreement is part of what the lab measures.

## Adding your own

The lab asks you to add at least two submissions of your own to this corpus, one of which is designed to fool the judge (for example, a paragraph that uses every transition word in the rubric but never makes a claim, or one that cites a precise-sounding number that supports nothing). Add them as `s13.txt`, `s14.txt`, and so on in `submissions/`, and as matching rows in `dataset.csv` if you are on the no-code path.

All files in this pack are synthetic. Every paragraph was written for this lab; none is real student work, and none of the numbers or events they mention are real.
