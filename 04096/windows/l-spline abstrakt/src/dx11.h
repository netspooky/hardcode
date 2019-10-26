#pragma once

#include <d3d11.h>
#include <d3dx11.h>
#include <d3dx10.h>

#pragma comment (lib, "d3d11.lib")
#pragma comment (lib, "d3dx11.lib")
#pragma comment (lib, "d3dx10.lib")

IDXGISwapChain *swapchain;             // the pointer to the swap chain interface
ID3D11Device *dev;                     // the pointer to our Direct3D device interface
ID3D11DeviceContext *devcon;           // the pointer to our Direct3D device context
ID3D11RenderTargetView *backbuffer;


D3D11_INPUT_ELEMENT_DESC default_inputdesc[2] = {{"POSITION",0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0, D3D11_INPUT_PER_VERTEX_DATA, 0},
												 {"COLOR",0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, D3D11_APPEND_ALIGNED_ELEMENT, D3D11_INPUT_PER_VERTEX_DATA, 0}};
ID3D10Blob* default_vs1_buffer;
ID3D10Blob* default_ps1_buffer;
ID3D11VertexShader * default_vs1;
ID3D11PixelShader * default_ps1;
ID3D11InputLayout* default_layout;
ID3D11Buffer *vxbuffer1;

struct VertexType
{
	D3DXVECTOR3 pos;
	D3DXVECTOR4 color;
};


void InitShader()
{
	char const shader_str[] = ""
	"struct VxInput{float4 p : POSITION; float4 c : COLOR;};"
	"struct PxInput{float4 p : SV_POSITION; float4 c : COLOR;};"
	"PxInput VXShader(VxInput v) {PxInput p; p.p=v.p; p.c=v.c; return p;}"
	"float4 PXShader(PxInput p) : SV_TARGET { return float4(1.0,1.0,1.0,1.0); }"
	;

	/*"technique10 T1 { pass P0 {"
    "    SetVertexShader(CompileShader(vs_4_0, VXShader()));"
    "    SetGeometryShader(NULL);"
    "    SetPixelShader(CompileShader(ps_4_0, PXShader()));"
    "}}"	//D3DX11Create*/

	D3DX11CompileFromMemory(shader_str, strlen(shader_str), 0, 0, 0, "VXShader", "vs_5_0", 0,0, 0, &default_vs1_buffer, 0,0);
	dev->CreateVertexShader(default_vs1_buffer->GetBufferPointer(), default_vs1_buffer->GetBufferSize(), 0, &default_vs1);
	D3DX11CompileFromMemory(shader_str, strlen(shader_str), 0, 0, 0, "PXShader", "ps_5_0", 0,0, 0, &default_ps1_buffer, 0,0);
	dev->CreatePixelShader(default_ps1_buffer->GetBufferPointer(), default_ps1_buffer->GetBufferSize(), 0, &default_ps1);
	dev->CreateInputLayout(default_inputdesc, 2, default_vs1_buffer->GetBufferPointer(), default_vs1_buffer->GetBufferSize(), &default_layout);
}

void InitGraphics(HWND hwnd)
{
    DXGI_SWAP_CHAIN_DESC scd=
    {
		{0,0,{0,0},DXGI_FORMAT_R8G8B8A8_UNORM,DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED,DXGI_MODE_SCALING_UNSPECIFIED},
	{4,0},
    DXGI_USAGE_RENDER_TARGET_OUTPUT,
    1,
    hwnd,
    0,
    DXGI_SWAP_EFFECT_DISCARD,
    0
	};
    //scd.BufferCount = 1;                                    // one back buffer
    //scd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;     // use 32-bit color
    //scd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;      // how swap chain is to be used
    //scd.OutputWindow = hwnd;                                // the window to be used
    //scd.SampleDesc.Count = 4;                               // how many multisamples

#ifndef FULLSCREEN
	scd.Windowed = TRUE;                                    // windowed/full-screen mode
#endif

	D3D11CreateDeviceAndSwapChain(0, D3D_DRIVER_TYPE_HARDWARE, 0,0,0,0, D3D11_SDK_VERSION, &scd, &swapchain, &dev, 0, &devcon);

	ID3D11Texture2D *pBackBuffer;
    swapchain->GetBuffer(0, __uuidof(ID3D11Texture2D), (LPVOID*)&pBackBuffer);
	dev->CreateRenderTargetView(pBackBuffer, NULL, &backbuffer);
    //pBackBuffer->Release();
	devcon->OMSetRenderTargets(1, &backbuffer, NULL);

	D3D11_VIEWPORT viewport = {0,0, XRES, YRES, 0,0};
    devcon->RSSetViewports(1, &viewport);

	float z = 0.5f;
	VertexType vertices[6] = 
	{
		{D3DXVECTOR3(0,0.5f,z), D3DXVECTOR4(1.f,0,0,1.f)},
		{D3DXVECTOR3(0.5f,0.5f,z), D3DXVECTOR4(1.f,0,0,1.f)},
		{D3DXVECTOR3(-0.5f,-0.1f,z), D3DXVECTOR4(1.f,0,0,1.f)},
		{D3DXVECTOR3(0.2f,0.2f,z), D3DXVECTOR4(1.f,0,0,1.f)},
		{D3DXVECTOR3(0,-10.0f,z), D3DXVECTOR4(1.f,0,0,1.f)},
		{D3DXVECTOR3(200.0f,200.0f,z), D3DXVECTOR4(1.f,0,0,1.f)}
	};

	const int vx_count = 6;
	D3D11_BUFFER_DESC vertexBufferDesc = {sizeof(VertexType) * vx_count, D3D11_USAGE_DEFAULT, D3D11_BIND_VERTEX_BUFFER, 0,0,0};
	D3D11_SUBRESOURCE_DATA vertexData = {vertices, 0, 0};

	dev->CreateBuffer(&vertexBufferDesc, &vertexData, &vxbuffer1);

	InitShader();
}

void DrawScene()
{
	float col[4] = {0.01f,0,0,0.9f};
	devcon->ClearRenderTargetView(backbuffer, col);

	devcon->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_LINESTRIP);
	UINT stride = sizeof(VertexType);
	UINT offset = 0;
	devcon->IASetVertexBuffers(0, 1, &vxbuffer1, &stride,&offset);
	devcon->IASetInputLayout(default_layout);
	devcon->VSSetShader(default_vs1, 0,0);
	devcon->PSSetShader(default_ps1, 0,0);

	devcon->Draw(6, 0);

	swapchain->Present(0,0);
}
