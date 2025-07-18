<!--
SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
SPDX-License-Identifier: LicenseRef-NvidiaProprietary

NVIDIA CORPORATION, its affiliates and licensors retain all intellectual
property and proprietary rights in and to this material, related
documentation and any modifications thereto. Any use, reproduction,
disclosure or distribution of this material and related documentation
without an express license agreement from NVIDIA CORPORATION or
its affiliates is strictly prohibited.
-->

<script lang="ts">
	import Video from "./shared/Video.svelte";
	import { playable } from "./shared/utils";
	import { type FileData } from "@gradio/client";

	export let type: "gallery" | "table";
	export let selected = false;
	export let value: { video: FileData; subtitles: FileData | null } | null;
	export let loop: boolean;
	let video: HTMLVideoElement;

	async function init(): Promise<void> {
		video.muted = true;
		video.playsInline = true;
		video.controls = false;
		video.setAttribute("muted", "");

		await video.play();
		video.pause();
	}
</script>

{#if value}
	{#if playable()}
		<div
			class="container"
			class:table={type === "table"}
			class:gallery={type === "gallery"}
			class:selected
		>
			<Video
				muted
				playsinline
				bind:node={video}
				on:loadeddata={init}
				on:mouseover={video.play.bind(video)}
				on:mouseout={video.pause.bind(video)}
				src={value?.video.url}
				is_stream={false}
				{loop}
			/>
		</div>
	{:else}
		<div>{value}</div>
	{/if}
{/if}

<style>
	.container {
		flex: none;
		max-width: none;
	}
	.container :global(video) {
		width: var(--size-full);
		height: var(--size-full);
		object-fit: cover;
	}

	.container:hover,
	.container.selected {
		border-color: var(--border-color-accent);
	}
	.container.table {
		margin: 0 auto;
		border: 2px solid var(--border-color-primary);
		border-radius: var(--radius-lg);
		overflow: hidden;
		width: var(--size-20);
		height: var(--size-20);
		object-fit: cover;
	}

	.container.gallery {
		height: var(--size-20);
		max-height: var(--size-20);
		object-fit: cover;
	}
</style>
