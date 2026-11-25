import asyncio
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.routers.gateway import router as fhir_router


async def _handle_health_probe(
    reader: asyncio.StreamReader, writer: asyncio.StreamWriter
) -> None:
    try:
        await reader.read(1024)
        writer.write(
            b'HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: 15\r\n\r\n{"status":"ok"}'
        )
        await writer.drain()
    except (ConnectionResetError, BrokenPipeError):
        pass
    finally:
        writer.close()
        await writer.wait_closed()


@asynccontextmanager
async def lifespan(app: FastAPI):
    health_server = await asyncio.start_server(_handle_health_probe, "0.0.0.0", 8081)
    try:
        yield
    finally:
        health_server.close()
        await health_server.wait_closed()


def create_app() -> FastAPI:
    app = FastAPI(
        title="FHIR Security Engine Gateway",
        description="PoC Edge Gateway for  Tokenization, WASM validation, and DLP",
        version="1.0.0",
        lifespan=lifespan,
    )

    app.include_router(fhir_router)
    return app


app = create_app()
