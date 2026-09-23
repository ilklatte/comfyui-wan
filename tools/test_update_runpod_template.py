#!/usr/bin/env python3
"""Behavior tests for the project-owned RunPod image promoter."""

from __future__ import annotations

import unittest

from update_runpod_template import PromotionError, Template, parse_template_ids, promote


REPOSITORY = "coohh88/comfyui-wan"


def image(release: int) -> str:
    return f"{REPOSITORY}:v{release}"


class FakeClient:
    def __init__(self, images: dict[str, str], mismatch_on: str | None = None) -> None:
        self.images = dict(images)
        self.mismatch_on = mismatch_on
        self.writes: list[tuple[str, str]] = []

    def get_template(self, template_id: str) -> Template:
        current = self.images[template_id]
        if self.mismatch_on == template_id and self.writes:
            current = image(999)
            self.mismatch_on = None
        return Template(template_id, f"Template {template_id}", current)

    def set_image(self, template: Template, image_name: str) -> None:
        self.writes.append((template.id, image_name))
        self.images[template.id] = image_name


class PromotionTests(unittest.TestCase):
    def test_updates_allowlisted_templates(self) -> None:
        client = FakeClient({"aaaaaaaaaa": image(1), "bbbbbbbbbb": image(2)})
        promote(client, client.images, image(3), REPOSITORY, emit=lambda _: None)
        self.assertEqual(set(client.images.values()), {image(3)})

    def test_is_idempotent(self) -> None:
        client = FakeClient({"aaaaaaaaaa": image(3)})
        promote(client, client.images, image(3), REPOSITORY, emit=lambda _: None)
        self.assertEqual(client.writes, [])

    def test_rejects_latest_and_wrong_repository(self) -> None:
        for desired in (f"{REPOSITORY}:latest", image(3).replace(REPOSITORY, "other/repo")):
            client = FakeClient({"aaaaaaaaaa": image(1)})
            with self.subTest(desired=desired), self.assertRaises(PromotionError):
                promote(client, client.images, desired, REPOSITORY, emit=lambda _: None)
            self.assertEqual(client.writes, [])

    def test_verification_failure_rolls_back(self) -> None:
        original = {"aaaaaaaaaa": image(1), "bbbbbbbbbb": image(2)}
        client = FakeClient(original, mismatch_on="bbbbbbbbbb")
        with self.assertRaises(PromotionError):
            promote(client, client.images, image(3), REPOSITORY, emit=lambda _: None)
        self.assertEqual(client.images, original)

    def test_template_id_parser(self) -> None:
        self.assertEqual(
            parse_template_ids("aaaaaaaaaa, bbbbbbbbbb"),
            ["aaaaaaaaaa", "bbbbbbbbbb"],
        )
        for value in ("", "aaaaaaaaaa,aaaaaaaaaa", "not-an-id"):
            with self.subTest(value=value), self.assertRaises(PromotionError):
                parse_template_ids(value)


if __name__ == "__main__":
    unittest.main()
