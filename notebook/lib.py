"""Async helpers for calling Azure AI Search knowledge base preview REST APIs."""

from __future__ import annotations

import aiohttp
import asyncio
from typing import Any, Dict, Optional


DEFAULT_API_VERSION = "2025-11-01-Preview"


async def _send_request(
	method: str,
	endpoint: str,
	path: str,
	api_key: str,
	*,
	api_version: str = DEFAULT_API_VERSION,
	session: Optional[aiohttp.ClientSession] = None,
	json_body: Optional[Dict[str, Any]] = None,
	params: Optional[Dict[str, Any]] = None,
	timeout: Optional[int] = None,
) -> Any:
	"""Issue an HTTP request and return the parsed response."""

	url = f"{endpoint.rstrip('/')}/{path.lstrip('/')}"
	query = {"api-version": api_version}
	if params:
		query.update(params)

	headers = {"api-key": api_key}
	need_close = False
	client = session

	if client is None:
		client = aiohttp.ClientSession()
		need_close = True

	# If caller provided None, apply default 90s fallback now (single point of defaulting)
	if timeout is None:
		timeout = 90

	# Convert simple numeric timeout into a granular aiohttp.ClientTimeout
	request_timeout: aiohttp.ClientTimeout
	if isinstance(timeout, (int, float)):
		request_timeout = aiohttp.ClientTimeout(total=timeout, sock_connect=timeout, sock_read=timeout)

	try:
		async with client.request(
			method,
			url,
			headers=headers,
			params=query,
			json=json_body,
			timeout=request_timeout,
		) as response:
			if response.status >= 400:
				detail = await response.text()
				raise aiohttp.ClientResponseError(
					request_info=response.request_info,
					history=response.history,
					status=response.status,
					message=detail or response.reason,
					headers=response.headers,
				)

			if response.status == 204:
				return None

			if response.content_type == "application/json":
				return await response.json()

			return await response.text()
	except asyncio.TimeoutError as e:  # type: ignore[name-defined]
		# Provide clearer guidance for users hitting timeouts
		raise asyncio.TimeoutError(
			f"Request to {url} timed out after {timeout} seconds. Increase 'timeout' parameter in helper call or set KB_CLIENT_TIMEOUT env var."
		) from e
	finally:
		if need_close:
			await client.close()


async def list_knowledge_bases(
	endpoint: str,
	api_key: str,
	*,
	api_version: str = DEFAULT_API_VERSION,
	session: Optional[aiohttp.ClientSession] = None,
	timeout: Optional[int] = None,
) -> Any:
	return await _send_request(
		"GET",
		endpoint,
		"/knowledgebases",
		api_key,
		api_version=api_version,
		session=session,
		timeout=timeout,
	)


async def get_knowledge_base(
	endpoint: str,
	api_key: str,
	knowledge_base_name: str,
	*,
	api_version: str = DEFAULT_API_VERSION,
	session: Optional[aiohttp.ClientSession] = None,
	timeout: Optional[int] = None,
) -> Any:
	path = f"/knowledgebases/{knowledge_base_name}"
	return await _send_request(
		"GET",
		endpoint,
		path,
		api_key,
		api_version=api_version,
		session=session,
		timeout=timeout,
	)


async def create_or_update_knowledge_base(
	endpoint: str,
	api_key: str,
	knowledge_base_name: str,
	body: Dict[str, Any],
	*,
	api_version: str = DEFAULT_API_VERSION,
	session: Optional[aiohttp.ClientSession] = None,
	timeout: Optional[int] = None,
) -> Any:
	path = f"/knowledgebases/{knowledge_base_name}"
	return await _send_request(
		"PUT",
		endpoint,
		path,
		api_key,
		api_version=api_version,
		session=session,
		json_body=body,
		timeout=timeout,
	)


async def delete_knowledge_base(
	endpoint: str,
	api_key: str,
	knowledge_base_name: str,
	*,
	api_version: str = DEFAULT_API_VERSION,
	session: Optional[aiohttp.ClientSession] = None,
	timeout: Optional[int] = None,
) -> Any:
	path = f"/knowledgebases/{knowledge_base_name}"
	return await _send_request(
		"DELETE",
		endpoint,
		path,
		api_key,
		api_version=api_version,
		session=session,
		timeout=timeout,
	)


async def retrieve_from_knowledge_base(
	endpoint: str,
	api_key: str,
	knowledge_base_name: str,
	body: Dict[str, Any],
	*,
	api_version: str = DEFAULT_API_VERSION,
	session: Optional[aiohttp.ClientSession] = None,
	timeout: Optional[int] = None,
) -> Any:
	path = f"/knowledgebases/{knowledge_base_name}/retrieve"
	return await _send_request(
		"POST",
		endpoint,
		path,
		api_key,
		api_version=api_version,
		session=session,
		json_body=body,
		timeout=timeout,
	)


async def list_knowledge_sources(
	endpoint: str,
	api_key: str,
	*,
	api_version: str = DEFAULT_API_VERSION,
	session: Optional[aiohttp.ClientSession] = None,
	timeout: Optional[int] = None,
) -> Any:
	return await _send_request(
		"GET",
		endpoint,
		"/knowledgesources",
		api_key,
		api_version=api_version,
		session=session,
		timeout=timeout,
	)


async def get_knowledge_source(
	endpoint: str,
	api_key: str,
	knowledge_source_name: str,
	*,
	api_version: str = DEFAULT_API_VERSION,
	session: Optional[aiohttp.ClientSession] = None,
	timeout: Optional[int] = None,
) -> Any:
	path = f"/knowledgesources/{knowledge_source_name}"
	return await _send_request(
		"GET",
		endpoint,
		path,
		api_key,
		api_version=api_version,
		session=session,
		timeout=timeout,
	)


async def get_knowledge_source_status(
	endpoint: str,
	api_key: str,
	knowledge_source_name: str,
	*,
	api_version: str = DEFAULT_API_VERSION,
	session: Optional[aiohttp.ClientSession] = None,
	timeout: Optional[int] = None,
) -> Any:
	path = f"/knowledgesources/{knowledge_source_name}/status"
	return await _send_request(
		"GET",
		endpoint,
		path,
		api_key,
		api_version=api_version,
		session=session,
		timeout=timeout,
	)


async def create_or_update_knowledge_source(
	endpoint: str,
	api_key: str,
	knowledge_source_name: str,
	body: Dict[str, Any],
	*,
	api_version: str = DEFAULT_API_VERSION,
	session: Optional[aiohttp.ClientSession] = None,
	timeout: Optional[int] = None,
) -> Any:
	path = f"/knowledgesources/{knowledge_source_name}"
	return await _send_request(
		"PUT",
		endpoint,
		path,
		api_key,
		api_version=api_version,
		session=session,
		json_body=body,
		timeout=timeout,
	)


async def delete_knowledge_source(
	endpoint: str,
	api_key: str,
	knowledge_source_name: str,
	*,
	api_version: str = DEFAULT_API_VERSION,
	session: Optional[aiohttp.ClientSession] = None,
	timeout: Optional[int] = None,
) -> Any:
	path = f"/knowledgesources/{knowledge_source_name}"
	return await _send_request(
		"DELETE",
		endpoint,
		path,
		api_key,
		api_version=api_version,
		session=session,
		timeout=timeout,
	)


